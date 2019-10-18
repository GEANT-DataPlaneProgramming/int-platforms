//
// calculated_fields.p4: Calculated fields of Netcope P4 INT sink processing example.
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

// IPv4 ========================================================================
field_list ipv4_fields {
    ipv4.version;
    ipv4.ihl;
    ipv4.dscp;
    ipv4.ecn;
    ipv4.totalLen;
    ipv4.id;
    ipv4.flags;
    ipv4.fragOffset;
    ipv4.ttl;
    ipv4.protocol;
    // hdrChecksum is taken as 0s - therefore it can be ignored
    //ipv4.hdrChecksum;
    ipv4.srcAddr;
    ipv4.dstAddr;
}

field_list enc_ipv4_fields {
    enc_ipv4.version;
    enc_ipv4.ihl;
    enc_ipv4.dscp;
    enc_ipv4.ecn;
    enc_ipv4.totalLen;
    enc_ipv4.id;
    enc_ipv4.flags;
    enc_ipv4.fragOffset;
    enc_ipv4.ttl;
    enc_ipv4.protocol;
    // hdrChecksum is taken as 0s - therefore it can be ignored
    //enc_ipv4.hdrChecksum;
    enc_ipv4.srcAddr;
    enc_ipv4.dstAddr;
}

field_list_calculation ipv4_csum {
    input
    {
        ipv4_fields;
    }
    algorithm : csum16 ;
    output_width : 16 ;
}

field_list_calculation enc_ipv4_csum {
    input
    {
        enc_ipv4_fields;
    }
    algorithm : csum16 ;
    output_width : 16 ;
}
