//
// top.p4: Main file and control flow definitions of Netcope P4 INT sink processing example.
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

#include "headers.p4"
#include "parser.p4"
#include "tables.p4"
#include "calculated_fields.p4"

@pragma core_identification Netcope-P4-INT-sink-2.0
control ingress {
	if (valid(int_tail)) {
		apply(tab_remove_int);
		if (valid(gtp)) {
			apply(tab_update_enc_L4);
		} else {
			apply(tab_update_L4);
		}
	}
	if (valid(gtp)) {
		apply(tab_terminate_gtp);
	}
	apply(tab_send);
}
