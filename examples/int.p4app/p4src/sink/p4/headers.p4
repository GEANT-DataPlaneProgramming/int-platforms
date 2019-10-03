//
// headers.p4: Header definitions of Netcope P4 INT sink processing example.
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

// Ethernet ====================================================================
header_type ethernet_t {
    fields {
        dstAddr     : 48;
        srcAddr     : 48;
        etherType   : 16;
    }
}

// IP (v4, v6)  ================================================================
header_type ipv4_t {
    fields {
        version     : 4;
        ihl         : 4;
        dscp        : 6;
        ecn         : 2;
        totalLen    : 16;
        id          : 16;
        flags       : 3;
        fragOffset  : 13;
        ttl         : 8;
        protocol    : 8;
        hdrChecksum : 16;
        srcAddr     : 32;
        dstAddr     : 32;
    }

    //length          : (ihl)*4;
    //max_length      : 60;
}

header_type ipv6_t {
    fields {
        ver         : 4;
        trafClass   : 8;
        flowLab     : 20;
        payLen      : 16;
        nextHead    : 8;
        hopLim      : 8;
        srcAddr     : 128;
        dstAddr     : 128;
    }
}

// L4 protocols ================================================================
header_type tcp_t {
    fields {
        srcPort     : 16;
        dstPort     : 16;
        seqNum      : 32;
        ackNum      : 32;
        dataOffset  : 4;
        reserved    : 3;
        flags       : 9;
        winSize     : 16;
        csum        : 16;
        urgPoint    : 16;
    }

    //length          : (dataOffset)*4;
    //max_length      : 60;
}

header_type udp_t {
    fields {
        srcPort     : 16;
        dstPort     : 16;
        len         : 16;
        csum        : 16;
    }
}

// GTP =========================================================================
header_type gtp_start_t {
    fields {
        version         : 3;
        protType        : 1;
        reserved        : 1;
        flags           : 3;
        messageType     : 8;
        messageLen      : 16;
        teid            : 32;
    }
}

header_type gtp_optional_t {
    fields {
        seqNum          : 16;
        npduNum         : 8;
        nextExtHdr      : 8;
    }
}

// INT =========================================================================
// INT shim header
header_type intl4_shim_t {
    fields {
        int_type        : 8;
        rsvd1           : 8;
        len             : 8;
        rsvd2           : 8;
    }
}

// INT tail header for TCP/UDP
header_type intl4_tail_t {
    fields {
        next_proto      : 8;
        dest_port       : 16;
        dscp            : 8;
    }
}

// INT headers
header_type int_header_v1_0_t {
    fields {
        ver                     : 4;
        rep                     : 2;
        c                       : 1;
        e                       : 1;
        m                       : 1;
        rsvd1                   : 10;
        ins_cnt                 : 5;
        remaining_hop_cnt       : 8;
        instruction_map         : 16;
        rsvd2                   : 16;
    }
}

header_type int_header_v0_5_t {
    fields {
        ver                     : 4;
        rep                     : 2;
        c                       : 1;
        e                       : 1;
        rsvd1                   : 3;
        ins_cnt                 : 5;
        max_hop_count           : 8;
        total_hop_count         : 8;
        instruction_map         : 16;
        rsvd2                   : 16;
    }
}

// INT meta-value headers - different header for each value type
header_type int_switch_id_t {
    fields {
        switch_id       : 32;
    }
}

header_type int_port_ids_t {
    fields {
        ingress_port_id : 16;
        egress_port_id  : 16;
    }
}

header_type int_hop_latency_t {
    fields {
        hop_latency     : 32;
    }
}

header_type int_q_occupancy_t {
    fields {
        q_id            : 8;
        q_occupancy     : 24;
    }
}

header_type int_ingress_tstamp_t {
    fields {
        ingress_tstamp  : 32;
        egress_tstamp   : 32;
    }
}

header_type int_egress_tstamp_t {
    fields {
        egress_tstamp   : 32;
    }
}

header_type int_q_congestion_t {
    fields {
        q_id            : 8;
        q_congestion    : 24;
    }
}

header_type int_egress_port_tx_util_t {
    fields {
        egress_port_tx_util : 32;
    }
}

// Metadata ====================================================================
// Output netcope metadata
header_type netcope_metadata_t {
    fields {
        valid_int       : 1;
        hop0_vld        : 1;
        hop1_vld        : 1;
        hop2_vld        : 1;
        hop3_vld        : 1;
        hop4_vld        : 1;
        hop5_vld        : 1;
        IPsrc           : 32;
        IPdst           : 32;
        IPver           : 8;
        L4src           : 16;
        L4dst           : 16;
        L4proto         : 8;
        INTinsmap       : 16;
        INTinscnt       : 5;
        INTlen          : 8;
    }
}

// Internal metadata
header_type internal_metadata_t {
    fields {
        dscp            : 6;
        INTlenB         : 10;
    }
}
