//
// top.p4: Main file and control flow definitions of Netcope P4 INT source & transit processing example.
// Copyright (C) 2018 Netcope Technologies, a.s.
// Author(s): Michal Kekely <kekely@netcope.com>
//

//
// This file is part of Netcope distribution (https://github.com/netcope).
// Copyright (c) 2018 Netcope Technologies, a.s.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3.
//
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
// General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.
//

#include "defines.p4"
#include "headers.p4"
#include "parser.p4"
#include "tables.p4"

@pragma core_identification Netcope-P4-INT-source-2.0
control ingress {
	//-- general ---------------------------------------------------------------
	apply(tab_set_egress);
	//-- process_set_source_sink -----------------------------------------------
	apply(tb_set_source);
	apply(tb_set_sink);
	//--/process_set_source_sink -----------------------------------------------
	if (valid(udp) or valid(tcp)) {
        if (int_meta.source == 1) {
			//-- process_int_source --------------------------------------------
            apply(tb_int_source);
			//--/process_int_source --------------------------------------------
		}
		if(valid(int_header)) {
			//-- process_int_transit -------------------------------------------
			apply(tb_int_insert);
        	apply(tb_int_inst_0003);
			apply(tb_int_inst_0407);
			//--/process_int_transit -------------------------------------------
			//-- process_int_outer_encap ---------------------------------------
			if (valid(ipv4)) {
            	apply(int_update_ipv4);
        	}
        	if (valid(udp)) {
            	apply(int_update_udp);
        	}
        	if (valid(int_shim)) {
            	apply(int_update_shim);
			}
			//--/process_int_outer_encap ---------------------------------------
		}
	}
	// Add GTP if needed
	if (not(valid(gtp))) {
		if (valid(udp)) {
			apply(tab_add_gtp_to_udp);
		}
		if (valid(tcp)) {
			apply(tab_add_gtp_to_tcp);
		}
	}
}
