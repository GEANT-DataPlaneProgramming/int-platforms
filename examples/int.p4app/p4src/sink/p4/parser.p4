//
// parser.p4: Parser definitions of Netcope P4 INT sink processing example.
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

// Protocol numbers ============================================================
#define PROTOCOL_IPV4 		0x0800
#define PROTOCOL_IPV6 		0x86dd
#define PROTOCOL_TCP 		0x06
#define PROTOCOL_UDP 		0x11
#define GTPV1_PORT          2152 mask 0x00FFFF
#define INT_DSCP_WDP        0x010000 mask 0x3F0000
#define INT_DSCP            0x01

// Select statements of INT stack ==============================================
// The select consists of:
// instruction count (5b), instruction bit map (16b), lenght (8b)
#define INT_SELECT_CONCAT           md_netcope.INTinscnt,md_netcope.INTinsmap,md_netcope.INTlen
// When choosing the next instruction we want to mask out length and IC
// and then only set the corresponding bit
#define MASK_SWITCH_ID              0x00800000
#define VAL_SWITCH_ID               MASK_SWITCH_ID
#define MASK_PORT_IDS               0x00400000
#define VAL_PORT_IDS                MASK_PORT_IDS
#define MASK_HOP_LATENCY            0x00200000
#define VAL_HOP_LATENCY             MASK_HOP_LATENCY
#define MASK_Q_OCCUPANCY            0x00100000
#define VAL_Q_OCCUPANCY             MASK_Q_OCCUPANCY
#define MASK_INGRESS_TSTAMP         0x00080000
#define VAL_INGRESS_TSTAMP          MASK_INGRESS_TSTAMP
#define MASK_EGRESS_TSTAMP          0x00040000
#define VAL_EGRESS_TSTAMP           MASK_EGRESS_TSTAMP
#define MASK_Q_CONGESTION           0x00020000
#define VAL_Q_CONGESTION            MASK_Q_CONGESTION
#define MASK_EGRESS_PORT_TX_UTIL    0x00010000
#define VAL_EGRESS_PORT_TX_UTIL     MASK_EGRESS_PORT_TX_UTIL
// For length set either only length bits or also IC bits
#define MLI                         0x1F0000FF
#define ML                          0x000000FF
// Expected INT lengths based on number of hops (and IC)
// 0 hops always mean length of 4
#define LEN_HOPS_0                  0x00000004 mask ML
// 1 hop means length of 4+(IC*1) - this means 5 for IC=1, 6 for IC=2 and so on up to 12 for IC=8
#define LEN_HOPS_1                  0x01000005 mask MLI, 0x02000006 mask MLI, 0x03000007 mask MLI, 0x04000008 mask MLI, 0x05000009 mask MLI, 0x0600000A mask MLI, 0x0700000B mask MLI, 0x0800000C mask MLI
// 2 hops mean length of 4+(IC*2) - this means 6 for IC=1, 8 for IC=2 and so on up to 20 for IC=8
#define LEN_HOPS_2                  0x01000006 mask MLI, 0x02000008 mask MLI, 0x0300000A mask MLI, 0x0400000C mask MLI, 0x0500000E mask MLI, 0x06000010 mask MLI, 0x07000012 mask MLI, 0x08000014 mask MLI
// 3 hops mean length of 4+(IC*3) - this means 7 for IC=1, 10 for IC=2 and so on up to 28 for IC=8
#define LEN_HOPS_3                  0x01000007 mask MLI, 0x0200000A mask MLI, 0x0300000D mask MLI, 0x04000010 mask MLI, 0x05000013 mask MLI, 0x06000016 mask MLI, 0x07000019 mask MLI, 0x0800001C mask MLI
// 4 hops mean length of 4+(IC*4) - this means 8 for IC=1, 12 for IC=2 and so on up to 36 for IC=8
#define LEN_HOPS_4                  0x01000008 mask MLI, 0x0200000C mask MLI, 0x03000010 mask MLI, 0x04000014 mask MLI, 0x05000018 mask MLI, 0x0600001C mask MLI, 0x07000020 mask MLI, 0x08000024 mask MLI
// 5 hops mean length of 4+(IC*5) - this means 9 for IC=1, 14 for IC=2 and so on up to 44 for IC=8
#define LEN_HOPS_5                  0x01000009 mask MLI, 0x0200000E mask MLI, 0x03000013 mask MLI, 0x04000018 mask MLI, 0x0500001D mask MLI, 0x06000022 mask MLI, 0x07000027 mask MLI, 0x0800002C mask MLI
// 6 hops mean length of 4+(IC*6) - this means 10 for IC=1, 16 for IC=2 and so on up to 52 for IC=8
#define LEN_HOPS_6                  0x0100000A mask MLI, 0x02000010 mask MLI, 0x03000016 mask MLI, 0x0400001C mask MLI, 0x05000022 mask MLI, 0x06000028 mask MLI, 0x0700002E mask MLI, 0x08000034 mask MLI

// Instances of headers ========================================================
header ethernet_t		            ethernet;
header ipv4_t                       ipv4;
//header ipv6_t                     ipv6;
header tcp_t                        tcp;
header udp_t                        udp;
header gtp_start_t                  gtp;
//header gtp_optional_t             gtp_opt;
header ipv4_t                       enc_ipv4;
//header ipv6_t                     enc_ipv6;
//header tcp_t                      enc_tcp;
header udp_t                        enc_udp;
header intl4_shim_t                 int_shim;
header intl4_tail_t                 int_tail;
header int_header_v0_5_t            int_header;
//header int_header_v1_0_t            int_header;

header int_switch_id_t              int_switch_id_0;
header int_port_ids_t               int_port_ids_0;
header int_hop_latency_t            int_hop_latency_0;
header int_q_occupancy_t            int_q_occupancy_0;
header int_ingress_tstamp_t         int_ingress_tstamp_0;
header int_egress_tstamp_t          int_egress_tstamp_0;
header int_q_congestion_t           int_q_congestion_0;
header int_egress_port_tx_util_t    int_egress_port_tx_util_0;

header int_switch_id_t              int_switch_id_1;
header int_port_ids_t               int_port_ids_1;
header int_hop_latency_t            int_hop_latency_1;
header int_q_occupancy_t            int_q_occupancy_1;
header int_ingress_tstamp_t         int_ingress_tstamp_1;
header int_egress_tstamp_t          int_egress_tstamp_1;
header int_q_congestion_t           int_q_congestion_1;
header int_egress_port_tx_util_t    int_egress_port_tx_util_1;

header int_switch_id_t              int_switch_id_2;
header int_port_ids_t               int_port_ids_2;
header int_hop_latency_t            int_hop_latency_2;
header int_q_occupancy_t            int_q_occupancy_2;
header int_ingress_tstamp_t         int_ingress_tstamp_2;
header int_egress_tstamp_t          int_egress_tstamp_2;
header int_q_congestion_t           int_q_congestion_2;
header int_egress_port_tx_util_t    int_egress_port_tx_util_2;

header int_switch_id_t              int_switch_id_3;
header int_port_ids_t               int_port_ids_3;
header int_hop_latency_t            int_hop_latency_3;
header int_q_occupancy_t            int_q_occupancy_3;
header int_ingress_tstamp_t         int_ingress_tstamp_3;
header int_egress_tstamp_t          int_egress_tstamp_3;
header int_q_congestion_t           int_q_congestion_3;
header int_egress_port_tx_util_t    int_egress_port_tx_util_3;

header int_switch_id_t              int_switch_id_4;
header int_port_ids_t               int_port_ids_4;
header int_hop_latency_t            int_hop_latency_4;
header int_q_occupancy_t            int_q_occupancy_4;
header int_ingress_tstamp_t         int_ingress_tstamp_4;
header int_egress_tstamp_t          int_egress_tstamp_4;
header int_q_congestion_t           int_q_congestion_4;
header int_egress_port_tx_util_t    int_egress_port_tx_util_4;

header int_switch_id_t              int_switch_id_5;
header int_port_ids_t               int_port_ids_5;
header int_hop_latency_t            int_hop_latency_5;
header int_q_occupancy_t            int_q_occupancy_5;
header int_ingress_tstamp_t         int_ingress_tstamp_5;
header int_egress_tstamp_t          int_egress_tstamp_5;
header int_q_congestion_t           int_q_congestion_5;
header int_egress_port_tx_util_t    int_egress_port_tx_util_5;

// Instances of metadata =======================================================
metadata netcope_metadata_t         md_netcope;
metadata internal_metadata_t        internal_metadata;

// Parse graph =================================================================
// Start
parser start {
    set_metadata(md_netcope.valid_int,0);
    set_metadata(md_netcope.hop0_vld,0);
    set_metadata(md_netcope.hop1_vld,0);
    set_metadata(md_netcope.hop2_vld,0);
    set_metadata(md_netcope.hop3_vld,0);
    set_metadata(md_netcope.hop4_vld,0);
    set_metadata(md_netcope.hop5_vld,0);
    return parse_ethernet;
}

// Ethernet
parser parse_ethernet {
    extract(ethernet);
    return select(latest.etherType) {
        PROTOCOL_IPV4   : parse_ipv4;
        default			: ingress;
    }
}

// IPv4
parser parse_ipv4 {
    extract(ipv4);
    set_metadata(md_netcope.IPsrc,latest.srcAddr);
    set_metadata(md_netcope.IPdst,latest.dstAddr);
    set_metadata(md_netcope.IPver,4);
    set_metadata(internal_metadata.dscp,latest.dscp);
    return select(latest.protocol) {
        PROTOCOL_UDP    : parse_udp;
        PROTOCOL_TCP    : parse_tcp;
        default			: ingress;
    }
}

// UDP
parser parse_udp {
    extract(udp);
    set_metadata(md_netcope.L4src,latest.srcPort);
    set_metadata(md_netcope.L4dst,latest.dstPort);
    set_metadata(md_netcope.L4proto,PROTOCOL_UDP);
    return select(internal_metadata.dscp,latest.dstPort) {
        // Either the port corresponding to GTP was set
        GTPV1_PORT      : parse_gtp;
        // Or there is no GTP so just check if there is INT (based on DSCP value)
        INT_DSCP_WDP    : parse_int_shim;
        default			: ingress;
    }
}

// TCP or TCP within GTP
parser parse_tcp {
    extract(tcp);
    set_metadata(md_netcope.L4src,latest.srcPort);
    set_metadata(md_netcope.L4dst,latest.dstPort);
    set_metadata(md_netcope.L4proto,PROTOCOL_TCP);
    return select(internal_metadata.dscp) {
        INT_DSCP        : parse_int_shim;
        default			: ingress;
    }
}

// GTP
parser parse_gtp {
    extract(gtp);
    return select(current(0,4)) {
        4               : parse_enc_ipv4;
        default			: ingress;
    }
}

// IPv4 within GTP
parser parse_enc_ipv4 {
    extract(enc_ipv4);
    set_metadata(md_netcope.IPsrc,latest.srcAddr);
    set_metadata(md_netcope.IPdst,latest.dstAddr);
    set_metadata(md_netcope.IPver,4);
    set_metadata(internal_metadata.dscp,latest.dscp);
    return select(latest.protocol) {
        PROTOCOL_UDP    : parse_enc_udp;
        PROTOCOL_TCP    : parse_tcp;
        default			: ingress;
    }
}

// UDP within GTP
parser parse_enc_udp {
    extract(enc_udp);
    set_metadata(md_netcope.L4src,latest.srcPort);
    set_metadata(md_netcope.L4dst,latest.dstPort);
    set_metadata(md_netcope.L4proto,PROTOCOL_UDP);
    return select(internal_metadata.dscp) {
        INT_DSCP        : parse_int_shim;
        default			: ingress;
    }
}

// INT shim header
parser parse_int_shim {
    extract(int_shim);
    set_metadata(md_netcope.INTlen,latest.len);
    return parse_int_header;
}

// INT metadata header
parser parse_int_header {
    extract(int_header);
    set_metadata(md_netcope.INTinsmap,latest.instruction_map);
	set_metadata(md_netcope.INTinscnt,latest.ins_cnt);
    return select(latest.ins_cnt,latest.instruction_map,md_netcope.INTlen) {
        // Check if there are any hops
        LEN_HOPS_0                                              : parse_int_tail;
        // Otherwise ignore length and choose based on instruction map
        VAL_SWITCH_ID mask MASK_SWITCH_ID                       : parse_switch_id_0;
        VAL_PORT_IDS mask MASK_PORT_IDS                         : parse_port_ids_0;
        //VAL_HOP_LATENCY mask MASK_HOP_LATENCY                   : parse_hop_latency_0;
        VAL_Q_OCCUPANCY mask MASK_Q_OCCUPANCY                   : parse_q_occupancy_0;
        VAL_INGRESS_TSTAMP mask MASK_INGRESS_TSTAMP             : parse_ingress_tstamp_0;
        //VAL_EGRESS_TSTAMP mask MASK_EGRESS_TSTAMP               : parse_egress_tstamp_0;
        //VAL_Q_CONGESTION mask MASK_Q_CONGESTION                 : parse_q_congestion_0;
        //VAL_EGRESS_PORT_TX_UTIL mask MASK_EGRESS_PORT_TX_UTIL   : parse_egressport_tx_util_0;
        default			                                        : ingress;
    }
}




// INT instructions of first hop
parser parse_switch_id_0 {
    extract(int_switch_id_0);
    set_metadata(md_netcope.hop0_vld,1);
    return select(INT_SELECT_CONCAT) {
        // Check if there is any other instruction within the same hop
        VAL_PORT_IDS mask MASK_PORT_IDS                         : parse_port_ids_0;
        //VAL_HOP_LATENCY mask MASK_HOP_LATENCY                   : parse_hop_latency_0;
        VAL_Q_OCCUPANCY mask MASK_Q_OCCUPANCY                   : parse_q_occupancy_0;
        VAL_INGRESS_TSTAMP mask MASK_INGRESS_TSTAMP             : parse_ingress_tstamp_0;
        //VAL_EGRESS_TSTAMP mask MASK_EGRESS_TSTAMP               : parse_egress_tstamp_0;
        //VAL_Q_CONGESTION mask MASK_Q_CONGESTION                 : parse_q_congestion_0;
        //VAL_EGRESS_PORT_TX_UTIL mask MASK_EGRESS_PORT_TX_UTIL   : parse_egressport_tx_util_0;
        // Otherwise check if this is last hop
        LEN_HOPS_1                                              : parse_int_tail;
        // Otherwise start parsing next hop
        VAL_SWITCH_ID mask MASK_SWITCH_ID                       : parse_switch_id_1;
        default			                                        : ingress;
    }
}
parser parse_port_ids_0 {
    extract(int_port_ids_0);
    set_metadata(md_netcope.hop0_vld,1);
    return select(INT_SELECT_CONCAT) {
        // Check if there is any other instruction within the same hop
        //VAL_HOP_LATENCY mask MASK_HOP_LATENCY                   : parse_hop_latency_0;
        VAL_Q_OCCUPANCY mask MASK_Q_OCCUPANCY                   : parse_q_occupancy_0;
        VAL_INGRESS_TSTAMP mask MASK_INGRESS_TSTAMP             : parse_ingress_tstamp_0;
        //VAL_EGRESS_TSTAMP mask MASK_EGRESS_TSTAMP               : parse_egress_tstamp_0;
        //VAL_Q_CONGESTION mask MASK_Q_CONGESTION                 : parse_q_congestion_0;
        //VAL_EGRESS_PORT_TX_UTIL mask MASK_EGRESS_PORT_TX_UTIL   : parse_egressport_tx_util_0;
        // Otherwise check if this is last hop
        LEN_HOPS_1                                              : parse_int_tail;
        // Otherwise start parsing next hop
        VAL_SWITCH_ID mask MASK_SWITCH_ID                       : parse_switch_id_1;
        VAL_PORT_IDS mask MASK_PORT_IDS                         : parse_port_ids_1;
        default			                                        : ingress;
    }
}

parser parse_hop_latency_0 {
    extract(int_hop_latency_0);
    set_metadata(md_netcope.hop0_vld,1);
    return select(INT_SELECT_CONCAT) {
        // Check if there is any other instruction within the same hop
        VAL_Q_OCCUPANCY mask MASK_Q_OCCUPANCY                   : parse_q_occupancy_0;
        VAL_INGRESS_TSTAMP mask MASK_INGRESS_TSTAMP             : parse_ingress_tstamp_0;
        //VAL_EGRESS_TSTAMP mask MASK_EGRESS_TSTAMP               : parse_egress_tstamp_0;
        //VAL_Q_CONGESTION mask MASK_Q_CONGESTION                 : parse_q_congestion_0;
        //VAL_EGRESS_PORT_TX_UTIL mask MASK_EGRESS_PORT_TX_UTIL   : parse_egressport_tx_util_0;
        // Otherwise check if this is last hop
        LEN_HOPS_1                                              : parse_int_tail;
        // Otherwise start parsing next hop
        VAL_SWITCH_ID mask MASK_SWITCH_ID                       : parse_switch_id_1;
        VAL_PORT_IDS mask MASK_PORT_IDS                         : parse_port_ids_1;
        //VAL_HOP_LATENCY mask MASK_HOP_LATENCY                   : parse_hop_latency_1;
        default			                                        : ingress;
    }
}

parser parse_q_occupancy_0 {
    extract(int_q_occupancy_0);
    set_metadata(md_netcope.hop0_vld,1);
    return select(INT_SELECT_CONCAT) {
        // Check if there is any other instruction within the same hop
        VAL_INGRESS_TSTAMP mask MASK_INGRESS_TSTAMP             : parse_ingress_tstamp_0;
        //VAL_EGRESS_TSTAMP mask MASK_EGRESS_TSTAMP               : parse_egress_tstamp_0;
        //VAL_Q_CONGESTION mask MASK_Q_CONGESTION                 : parse_q_congestion_0;
        //VAL_EGRESS_PORT_TX_UTIL mask MASK_EGRESS_PORT_TX_UTIL   : parse_egressport_tx_util_0;
        // Otherwise check if this is last hop
        LEN_HOPS_1                                              : parse_int_tail;
        // Otherwise start parsing next hop
        VAL_SWITCH_ID mask MASK_SWITCH_ID                       : parse_switch_id_1;
        VAL_PORT_IDS mask MASK_PORT_IDS                         : parse_port_ids_1;
        //VAL_HOP_LATENCY mask MASK_HOP_LATENCY                   : parse_hop_latency_1;
        VAL_Q_OCCUPANCY mask MASK_Q_OCCUPANCY                   : parse_q_occupancy_1;
        default			                                        : ingress;
    }
}

parser parse_ingress_tstamp_0 {
    extract(int_ingress_tstamp_0);
    set_metadata(md_netcope.hop0_vld,1);
    return select(INT_SELECT_CONCAT) {
        // Check if there is any other instruction within the same hop
        //VAL_EGRESS_TSTAMP mask MASK_EGRESS_TSTAMP               : parse_egress_tstamp_0;
        //VAL_Q_CONGESTION mask MASK_Q_CONGESTION                 : parse_q_congestion_0;
        //VAL_EGRESS_PORT_TX_UTIL mask MASK_EGRESS_PORT_TX_UTIL   : parse_egressport_tx_util_0;
        // Otherwise check if this is last hop
        LEN_HOPS_1                                              : parse_int_tail;
        // Otherwise start parsing next hop
        VAL_SWITCH_ID mask MASK_SWITCH_ID                       : parse_switch_id_1;
        VAL_PORT_IDS mask MASK_PORT_IDS                         : parse_port_ids_1;
        //VAL_HOP_LATENCY mask MASK_HOP_LATENCY                   : parse_hop_latency_1;
        VAL_Q_OCCUPANCY mask MASK_Q_OCCUPANCY                   : parse_q_occupancy_1;
        VAL_INGRESS_TSTAMP mask MASK_INGRESS_TSTAMP             : parse_ingress_tstamp_1;
        default			                                        : ingress;
    }
}

parser parse_egress_tstamp_0 {
    extract(int_egress_tstamp_0);
    set_metadata(md_netcope.hop0_vld,1);
    return select(INT_SELECT_CONCAT) {
        // Check if there is any other instruction within the same hop
        //VAL_Q_CONGESTION mask MASK_Q_CONGESTION                 : parse_q_congestion_0;
        //VAL_EGRESS_PORT_TX_UTIL mask MASK_EGRESS_PORT_TX_UTIL   : parse_egressport_tx_util_0;
        // Otherwise check if this is last hop
        LEN_HOPS_1                                              : parse_int_tail;
        // Otherwise start parsing next hop
        VAL_SWITCH_ID mask MASK_SWITCH_ID                       : parse_switch_id_1;
        VAL_PORT_IDS mask MASK_PORT_IDS                         : parse_port_ids_1;
        //VAL_HOP_LATENCY mask MASK_HOP_LATENCY                   : parse_hop_latency_1;
        VAL_Q_OCCUPANCY mask MASK_Q_OCCUPANCY                   : parse_q_occupancy_1;
        VAL_INGRESS_TSTAMP mask MASK_INGRESS_TSTAMP             : parse_ingress_tstamp_1;
        //VAL_EGRESS_TSTAMP mask MASK_EGRESS_TSTAMP               : parse_egress_tstamp_1;
        default			                                        : ingress;
    }
}

parser parse_q_congestion_0 {
    extract(int_q_congestion_0);
    set_metadata(md_netcope.hop0_vld,1);
    return select(INT_SELECT_CONCAT) {
        // Check if there is any other instruction within the same hop
        //VAL_EGRESS_PORT_TX_UTIL mask MASK_EGRESS_PORT_TX_UTIL   : parse_egressport_tx_util_0;
        // Otherwise check if this is last hop
        LEN_HOPS_1                                              : parse_int_tail;
        // Otherwise start parsing next hop
        VAL_SWITCH_ID mask MASK_SWITCH_ID                       : parse_switch_id_1;
        VAL_PORT_IDS mask MASK_PORT_IDS                         : parse_port_ids_1;
        //VAL_HOP_LATENCY mask MASK_HOP_LATENCY                   : parse_hop_latency_1;
        VAL_Q_OCCUPANCY mask MASK_Q_OCCUPANCY                   : parse_q_occupancy_1;
        VAL_INGRESS_TSTAMP mask MASK_INGRESS_TSTAMP             : parse_ingress_tstamp_1;
        //VAL_EGRESS_TSTAMP mask MASK_EGRESS_TSTAMP               : parse_egress_tstamp_1;
        //VAL_Q_CONGESTION mask MASK_Q_CONGESTION                 : parse_q_congestion_1;
        default			                                        : ingress;
    }
}

parser parse_egressport_tx_util_0 {
    extract(int_egress_port_tx_util_0);
    set_metadata(md_netcope.hop0_vld,1);
    return select(INT_SELECT_CONCAT) {
        // Check if there is any other instruction within the same hop
        // Otherwise check if this is last hop
        LEN_HOPS_1                                              : parse_int_tail;
        // Otherwise start parsing next hop
        VAL_SWITCH_ID mask MASK_SWITCH_ID                       : parse_switch_id_1;
        VAL_PORT_IDS mask MASK_PORT_IDS                         : parse_port_ids_1;
        //VAL_HOP_LATENCY mask MASK_HOP_LATENCY                   : parse_hop_latency_1;
        VAL_Q_OCCUPANCY mask MASK_Q_OCCUPANCY                   : parse_q_occupancy_1;
        VAL_INGRESS_TSTAMP mask MASK_INGRESS_TSTAMP             : parse_ingress_tstamp_1;
        //VAL_EGRESS_TSTAMP mask MASK_EGRESS_TSTAMP               : parse_egress_tstamp_1;
        //VAL_Q_CONGESTION mask MASK_Q_CONGESTION                 : parse_q_congestion_1;
        //VAL_EGRESS_PORT_TX_UTIL mask MASK_EGRESS_PORT_TX_UTIL   : parse_egressport_tx_util_1;
        default			                                        : ingress;
    }
}




// INT instructions of second hop
parser parse_switch_id_1 {
    extract(int_switch_id_1);
    set_metadata(md_netcope.hop1_vld,1);
    return select(INT_SELECT_CONCAT) {
        // Check if there is any other instruction within the same hop
        VAL_PORT_IDS mask MASK_PORT_IDS                         : parse_port_ids_1;
        //VAL_HOP_LATENCY mask MASK_HOP_LATENCY                   : parse_hop_latency_1;
        VAL_Q_OCCUPANCY mask MASK_Q_OCCUPANCY                   : parse_q_occupancy_1;
        VAL_INGRESS_TSTAMP mask MASK_INGRESS_TSTAMP             : parse_ingress_tstamp_1;
        //VAL_EGRESS_TSTAMP mask MASK_EGRESS_TSTAMP               : parse_egress_tstamp_1;
        //VAL_Q_CONGESTION mask MASK_Q_CONGESTION                 : parse_q_congestion_1;
        //VAL_EGRESS_PORT_TX_UTIL mask MASK_EGRESS_PORT_TX_UTIL   : parse_egressport_tx_util_1;
        // Otherwise check if this is last hop
        LEN_HOPS_2                                              : parse_int_tail;
        // Otherwise start parsing next hop
        VAL_SWITCH_ID mask MASK_SWITCH_ID                       : parse_switch_id_2;
        default			                                        : ingress;
    }
}
parser parse_port_ids_1 {
    extract(int_port_ids_1);
    set_metadata(md_netcope.hop1_vld,1);
    return select(INT_SELECT_CONCAT) {
        // Check if there is any other instruction within the same hop
        //VAL_HOP_LATENCY mask MASK_HOP_LATENCY                   : parse_hop_latency_1;
        VAL_Q_OCCUPANCY mask MASK_Q_OCCUPANCY                   : parse_q_occupancy_1;
        VAL_INGRESS_TSTAMP mask MASK_INGRESS_TSTAMP             : parse_ingress_tstamp_1;
        //VAL_EGRESS_TSTAMP mask MASK_EGRESS_TSTAMP               : parse_egress_tstamp_1;
        //VAL_Q_CONGESTION mask MASK_Q_CONGESTION                 : parse_q_congestion_1;
        //VAL_EGRESS_PORT_TX_UTIL mask MASK_EGRESS_PORT_TX_UTIL   : parse_egressport_tx_util_1;
        // Otherwise check if this is last hop
        LEN_HOPS_2                                              : parse_int_tail;
        // Otherwise start parsing next hop
        VAL_SWITCH_ID mask MASK_SWITCH_ID                       : parse_switch_id_2;
        VAL_PORT_IDS mask MASK_PORT_IDS                         : parse_port_ids_2;
        default			                                        : ingress;
    }
}

parser parse_hop_latency_1 {
    extract(int_hop_latency_1);
    set_metadata(md_netcope.hop1_vld,1);
    return select(INT_SELECT_CONCAT) {
        // Check if there is any other instruction within the same hop
        VAL_Q_OCCUPANCY mask MASK_Q_OCCUPANCY                   : parse_q_occupancy_1;
        VAL_INGRESS_TSTAMP mask MASK_INGRESS_TSTAMP             : parse_ingress_tstamp_1;
        //VAL_EGRESS_TSTAMP mask MASK_EGRESS_TSTAMP               : parse_egress_tstamp_1;
        //VAL_Q_CONGESTION mask MASK_Q_CONGESTION                 : parse_q_congestion_1;
        //VAL_EGRESS_PORT_TX_UTIL mask MASK_EGRESS_PORT_TX_UTIL   : parse_egressport_tx_util_1;
        // Otherwise check if this is last hop
        LEN_HOPS_2                                              : parse_int_tail;
        // Otherwise start parsing next hop
        VAL_SWITCH_ID mask MASK_SWITCH_ID                       : parse_switch_id_2;
        VAL_PORT_IDS mask MASK_PORT_IDS                         : parse_port_ids_2;
        //VAL_HOP_LATENCY mask MASK_HOP_LATENCY                   : parse_hop_latency_2;
        default			                                        : ingress;
    }
}

parser parse_q_occupancy_1 {
    extract(int_q_occupancy_1);
    set_metadata(md_netcope.hop1_vld,1);
    return select(INT_SELECT_CONCAT) {
        // Check if there is any other instruction within the same hop
        VAL_INGRESS_TSTAMP mask MASK_INGRESS_TSTAMP             : parse_ingress_tstamp_1;
        //VAL_EGRESS_TSTAMP mask MASK_EGRESS_TSTAMP               : parse_egress_tstamp_1;
        //VAL_Q_CONGESTION mask MASK_Q_CONGESTION                 : parse_q_congestion_1;
        //VAL_EGRESS_PORT_TX_UTIL mask MASK_EGRESS_PORT_TX_UTIL   : parse_egressport_tx_util_1;
        // Otherwise check if this is last hop
        LEN_HOPS_2                                              : parse_int_tail;
        // Otherwise start parsing next hop
        VAL_SWITCH_ID mask MASK_SWITCH_ID                       : parse_switch_id_2;
        VAL_PORT_IDS mask MASK_PORT_IDS                         : parse_port_ids_2;
        //VAL_HOP_LATENCY mask MASK_HOP_LATENCY                   : parse_hop_latency_2;
        VAL_Q_OCCUPANCY mask MASK_Q_OCCUPANCY                   : parse_q_occupancy_2;
        default			                                        : ingress;
    }
}

parser parse_ingress_tstamp_1 {
    extract(int_ingress_tstamp_1);
    set_metadata(md_netcope.hop1_vld,1);
    return select(INT_SELECT_CONCAT) {
        // Check if there is any other instruction within the same hop
        //VAL_EGRESS_TSTAMP mask MASK_EGRESS_TSTAMP               : parse_egress_tstamp_1;
        //VAL_Q_CONGESTION mask MASK_Q_CONGESTION                 : parse_q_congestion_1;
        //VAL_EGRESS_PORT_TX_UTIL mask MASK_EGRESS_PORT_TX_UTIL   : parse_egressport_tx_util_1;
        // Otherwise check if this is last hop
        LEN_HOPS_2                                              : parse_int_tail;
        // Otherwise start parsing next hop
        VAL_SWITCH_ID mask MASK_SWITCH_ID                       : parse_switch_id_2;
        VAL_PORT_IDS mask MASK_PORT_IDS                         : parse_port_ids_2;
        //VAL_HOP_LATENCY mask MASK_HOP_LATENCY                   : parse_hop_latency_2;
        VAL_Q_OCCUPANCY mask MASK_Q_OCCUPANCY                   : parse_q_occupancy_2;
        VAL_INGRESS_TSTAMP mask MASK_INGRESS_TSTAMP             : parse_ingress_tstamp_2;
        default			                                        : ingress;
    }
}

parser parse_egress_tstamp_1 {
    extract(int_egress_tstamp_1);
    set_metadata(md_netcope.hop1_vld,1);
    return select(INT_SELECT_CONCAT) {
        // Check if there is any other instruction within the same hop
        //VAL_Q_CONGESTION mask MASK_Q_CONGESTION                 : parse_q_congestion_1;
        //VAL_EGRESS_PORT_TX_UTIL mask MASK_EGRESS_PORT_TX_UTIL   : parse_egressport_tx_util_1;
        // Otherwise check if this is last hop
        LEN_HOPS_2                                              : parse_int_tail;
        // Otherwise start parsing next hop
        VAL_SWITCH_ID mask MASK_SWITCH_ID                       : parse_switch_id_2;
        VAL_PORT_IDS mask MASK_PORT_IDS                         : parse_port_ids_2;
        //VAL_HOP_LATENCY mask MASK_HOP_LATENCY                   : parse_hop_latency_2;
        VAL_Q_OCCUPANCY mask MASK_Q_OCCUPANCY                   : parse_q_occupancy_2;
        VAL_INGRESS_TSTAMP mask MASK_INGRESS_TSTAMP             : parse_ingress_tstamp_2;
        //VAL_EGRESS_TSTAMP mask MASK_EGRESS_TSTAMP               : parse_egress_tstamp_2;
        default			                                        : ingress;
    }
}

parser parse_q_congestion_1 {
    extract(int_q_congestion_1);
    set_metadata(md_netcope.hop1_vld,1);
    return select(INT_SELECT_CONCAT) {
        // Check if there is any other instruction within the same hop
        //VAL_EGRESS_PORT_TX_UTIL mask MASK_EGRESS_PORT_TX_UTIL   : parse_egressport_tx_util_1;
        // Otherwise check if this is last hop
        LEN_HOPS_2                                              : parse_int_tail;
        // Otherwise start parsing next hop
        VAL_SWITCH_ID mask MASK_SWITCH_ID                       : parse_switch_id_2;
        VAL_PORT_IDS mask MASK_PORT_IDS                         : parse_port_ids_2;
        //VAL_HOP_LATENCY mask MASK_HOP_LATENCY                   : parse_hop_latency_2;
        VAL_Q_OCCUPANCY mask MASK_Q_OCCUPANCY                   : parse_q_occupancy_2;
        VAL_INGRESS_TSTAMP mask MASK_INGRESS_TSTAMP             : parse_ingress_tstamp_2;
        //VAL_EGRESS_TSTAMP mask MASK_EGRESS_TSTAMP               : parse_egress_tstamp_2;
        //VAL_Q_CONGESTION mask MASK_Q_CONGESTION                 : parse_q_congestion_2;
        default			                                        : ingress;
    }
}

parser parse_egressport_tx_util_1 {
    extract(int_egress_port_tx_util_1);
    set_metadata(md_netcope.hop1_vld,1);
    return select(INT_SELECT_CONCAT) {
        // Check if there is any other instruction within the same hop
        // Otherwise check if this is last hop
        LEN_HOPS_2                                              : parse_int_tail;
        // Otherwise start parsing next hop
        VAL_SWITCH_ID mask MASK_SWITCH_ID                       : parse_switch_id_2;
        VAL_PORT_IDS mask MASK_PORT_IDS                         : parse_port_ids_2;
        //VAL_HOP_LATENCY mask MASK_HOP_LATENCY                   : parse_hop_latency_2;
        VAL_Q_OCCUPANCY mask MASK_Q_OCCUPANCY                   : parse_q_occupancy_2;
        VAL_INGRESS_TSTAMP mask MASK_INGRESS_TSTAMP             : parse_ingress_tstamp_2;
        //VAL_EGRESS_TSTAMP mask MASK_EGRESS_TSTAMP               : parse_egress_tstamp_2;
        //VAL_Q_CONGESTION mask MASK_Q_CONGESTION                 : parse_q_congestion_2;
        //VAL_EGRESS_PORT_TX_UTIL mask MASK_EGRESS_PORT_TX_UTIL   : parse_egressport_tx_util_2;
        default			                                        : ingress;
    }
}



// INT instructions of third hop
parser parse_switch_id_2 {
    extract(int_switch_id_2);
    set_metadata(md_netcope.hop2_vld,1);
    return select(INT_SELECT_CONCAT) {
        // Check if there is any other instruction within the same hop
        VAL_PORT_IDS mask MASK_PORT_IDS                         : parse_port_ids_2;
        //VAL_HOP_LATENCY mask MASK_HOP_LATENCY                   : parse_hop_latency_2;
        VAL_Q_OCCUPANCY mask MASK_Q_OCCUPANCY                   : parse_q_occupancy_2;
        VAL_INGRESS_TSTAMP mask MASK_INGRESS_TSTAMP             : parse_ingress_tstamp_2;
        //VAL_EGRESS_TSTAMP mask MASK_EGRESS_TSTAMP               : parse_egress_tstamp_2;
        //VAL_Q_CONGESTION mask MASK_Q_CONGESTION                 : parse_q_congestion_2;
        //VAL_EGRESS_PORT_TX_UTIL mask MASK_EGRESS_PORT_TX_UTIL   : parse_egressport_tx_util_2;
        // Otherwise check if this is last hop
        LEN_HOPS_3                                              : parse_int_tail;
        // Otherwise start parsing next hop
        VAL_SWITCH_ID mask MASK_SWITCH_ID                       : parse_switch_id_3;
        default			                                        : ingress;
    }
}
parser parse_port_ids_2 {
    extract(int_port_ids_2);
    set_metadata(md_netcope.hop2_vld,1);
    return select(INT_SELECT_CONCAT) {
        // Check if there is any other instruction within the same hop
        //VAL_HOP_LATENCY mask MASK_HOP_LATENCY                   : parse_hop_latency_2;
        VAL_Q_OCCUPANCY mask MASK_Q_OCCUPANCY                   : parse_q_occupancy_2;
        VAL_INGRESS_TSTAMP mask MASK_INGRESS_TSTAMP             : parse_ingress_tstamp_2;
        //VAL_EGRESS_TSTAMP mask MASK_EGRESS_TSTAMP               : parse_egress_tstamp_2;
        //VAL_Q_CONGESTION mask MASK_Q_CONGESTION                 : parse_q_congestion_2;
        //VAL_EGRESS_PORT_TX_UTIL mask MASK_EGRESS_PORT_TX_UTIL   : parse_egressport_tx_util_2;
        // Otherwise check if this is last hop
        LEN_HOPS_3                                              : parse_int_tail;
        // Otherwise start parsing next hop
        VAL_SWITCH_ID mask MASK_SWITCH_ID                       : parse_switch_id_3;
        VAL_PORT_IDS mask MASK_PORT_IDS                         : parse_port_ids_3;
        default			                                        : ingress;
    }
}

parser parse_hop_latency_2 {
    extract(int_hop_latency_2);
    set_metadata(md_netcope.hop2_vld,1);
    return select(INT_SELECT_CONCAT) {
        // Check if there is any other instruction within the same hop
        VAL_Q_OCCUPANCY mask MASK_Q_OCCUPANCY                   : parse_q_occupancy_2;
        VAL_INGRESS_TSTAMP mask MASK_INGRESS_TSTAMP             : parse_ingress_tstamp_2;
        //VAL_EGRESS_TSTAMP mask MASK_EGRESS_TSTAMP               : parse_egress_tstamp_2;
        //VAL_Q_CONGESTION mask MASK_Q_CONGESTION                 : parse_q_congestion_2;
        //VAL_EGRESS_PORT_TX_UTIL mask MASK_EGRESS_PORT_TX_UTIL   : parse_egressport_tx_util_2;
        // Otherwise check if this is last hop
        LEN_HOPS_3                                              : parse_int_tail;
        // Otherwise start parsing next hop
        VAL_SWITCH_ID mask MASK_SWITCH_ID                       : parse_switch_id_3;
        VAL_PORT_IDS mask MASK_PORT_IDS                         : parse_port_ids_3;
        //VAL_HOP_LATENCY mask MASK_HOP_LATENCY                   : parse_hop_latency_3;
        default			                                        : ingress;
    }
}

parser parse_q_occupancy_2 {
    extract(int_q_occupancy_2);
    set_metadata(md_netcope.hop2_vld,1);
    return select(INT_SELECT_CONCAT) {
        // Check if there is any other instruction within the same hop
        VAL_INGRESS_TSTAMP mask MASK_INGRESS_TSTAMP             : parse_ingress_tstamp_2;
        //VAL_EGRESS_TSTAMP mask MASK_EGRESS_TSTAMP               : parse_egress_tstamp_2;
        //VAL_Q_CONGESTION mask MASK_Q_CONGESTION                 : parse_q_congestion_2;
        //VAL_EGRESS_PORT_TX_UTIL mask MASK_EGRESS_PORT_TX_UTIL   : parse_egressport_tx_util_2;
        // Otherwise check if this is last hop
        LEN_HOPS_3                                              : parse_int_tail;
        // Otherwise start parsing next hop
        VAL_SWITCH_ID mask MASK_SWITCH_ID                       : parse_switch_id_3;
        VAL_PORT_IDS mask MASK_PORT_IDS                         : parse_port_ids_3;
        //VAL_HOP_LATENCY mask MASK_HOP_LATENCY                   : parse_hop_latency_3;
        VAL_Q_OCCUPANCY mask MASK_Q_OCCUPANCY                   : parse_q_occupancy_3;
        default			                                        : ingress;
    }
}

parser parse_ingress_tstamp_2 {
    extract(int_ingress_tstamp_2);
    set_metadata(md_netcope.hop2_vld,1);
    return select(INT_SELECT_CONCAT) {
        // Check if there is any other instruction within the same hop
        //VAL_EGRESS_TSTAMP mask MASK_EGRESS_TSTAMP               : parse_egress_tstamp_2;
        //VAL_Q_CONGESTION mask MASK_Q_CONGESTION                 : parse_q_congestion_2;
        //VAL_EGRESS_PORT_TX_UTIL mask MASK_EGRESS_PORT_TX_UTIL   : parse_egressport_tx_util_2;
        // Otherwise check if this is last hop
        LEN_HOPS_3                                              : parse_int_tail;
        // Otherwise start parsing next hop
        VAL_SWITCH_ID mask MASK_SWITCH_ID                       : parse_switch_id_3;
        VAL_PORT_IDS mask MASK_PORT_IDS                         : parse_port_ids_3;
        //VAL_HOP_LATENCY mask MASK_HOP_LATENCY                   : parse_hop_latency_3;
        VAL_Q_OCCUPANCY mask MASK_Q_OCCUPANCY                   : parse_q_occupancy_3;
        VAL_INGRESS_TSTAMP mask MASK_INGRESS_TSTAMP             : parse_ingress_tstamp_3;
        default			                                        : ingress;
    }
}

parser parse_egress_tstamp_2 {
    extract(int_egress_tstamp_2);
    set_metadata(md_netcope.hop2_vld,1);
    return select(INT_SELECT_CONCAT) {
        // Check if there is any other instruction within the same hop
        //VAL_Q_CONGESTION mask MASK_Q_CONGESTION                 : parse_q_congestion_2;
        //VAL_EGRESS_PORT_TX_UTIL mask MASK_EGRESS_PORT_TX_UTIL   : parse_egressport_tx_util_2;
        // Otherwise check if this is last hop
        LEN_HOPS_3                                              : parse_int_tail;
        // Otherwise start parsing next hop
        VAL_SWITCH_ID mask MASK_SWITCH_ID                       : parse_switch_id_3;
        VAL_PORT_IDS mask MASK_PORT_IDS                         : parse_port_ids_3;
        //VAL_HOP_LATENCY mask MASK_HOP_LATENCY                   : parse_hop_latency_3;
        VAL_Q_OCCUPANCY mask MASK_Q_OCCUPANCY                   : parse_q_occupancy_3;
        VAL_INGRESS_TSTAMP mask MASK_INGRESS_TSTAMP             : parse_ingress_tstamp_3;
        //VAL_EGRESS_TSTAMP mask MASK_EGRESS_TSTAMP               : parse_egress_tstamp_3;
        default			                                        : ingress;
    }
}

parser parse_q_congestion_2 {
    extract(int_q_congestion_2);
    set_metadata(md_netcope.hop2_vld,1);
    return select(INT_SELECT_CONCAT) {
        // Check if there is any other instruction within the same hop
        //VAL_EGRESS_PORT_TX_UTIL mask MASK_EGRESS_PORT_TX_UTIL   : parse_egressport_tx_util_2;
        // Otherwise check if this is last hop
        LEN_HOPS_3                                              : parse_int_tail;
        // Otherwise start parsing next hop
        VAL_SWITCH_ID mask MASK_SWITCH_ID                       : parse_switch_id_3;
        VAL_PORT_IDS mask MASK_PORT_IDS                         : parse_port_ids_3;
        //VAL_HOP_LATENCY mask MASK_HOP_LATENCY                   : parse_hop_latency_3;
        VAL_Q_OCCUPANCY mask MASK_Q_OCCUPANCY                   : parse_q_occupancy_3;
        VAL_INGRESS_TSTAMP mask MASK_INGRESS_TSTAMP             : parse_ingress_tstamp_3;
        //VAL_EGRESS_TSTAMP mask MASK_EGRESS_TSTAMP               : parse_egress_tstamp_3;
        //VAL_Q_CONGESTION mask MASK_Q_CONGESTION                 : parse_q_congestion_3;
        default			                                        : ingress;
    }
}

parser parse_egressport_tx_util_2 {
    extract(int_egress_port_tx_util_2);
    set_metadata(md_netcope.hop2_vld,1);
    return select(INT_SELECT_CONCAT) {
        // Check if there is any other instruction within the same hop
        // Otherwise check if this is last hop
        LEN_HOPS_3                                              : parse_int_tail;
        // Otherwise start parsing next hop
        VAL_SWITCH_ID mask MASK_SWITCH_ID                       : parse_switch_id_3;
        VAL_PORT_IDS mask MASK_PORT_IDS                         : parse_port_ids_3;
        //VAL_HOP_LATENCY mask MASK_HOP_LATENCY                   : parse_hop_latency_3;
        VAL_Q_OCCUPANCY mask MASK_Q_OCCUPANCY                   : parse_q_occupancy_3;
        VAL_INGRESS_TSTAMP mask MASK_INGRESS_TSTAMP             : parse_ingress_tstamp_3;
        //VAL_EGRESS_TSTAMP mask MASK_EGRESS_TSTAMP               : parse_egress_tstamp_3;
        //VAL_Q_CONGESTION mask MASK_Q_CONGESTION                 : parse_q_congestion_3;
        //VAL_EGRESS_PORT_TX_UTIL mask MASK_EGRESS_PORT_TX_UTIL   : parse_egressport_tx_util_3;
        default			                                        : ingress;
    }
}



// INT instructions of fourth hop
parser parse_switch_id_3 {
    extract(int_switch_id_3);
    set_metadata(md_netcope.hop3_vld,1);
    return select(INT_SELECT_CONCAT) {
        // Check if there is any other instruction within the same hop
        VAL_PORT_IDS mask MASK_PORT_IDS                         : parse_port_ids_3;
        //VAL_HOP_LATENCY mask MASK_HOP_LATENCY                   : parse_hop_latency_3;
        VAL_Q_OCCUPANCY mask MASK_Q_OCCUPANCY                   : parse_q_occupancy_3;
        VAL_INGRESS_TSTAMP mask MASK_INGRESS_TSTAMP             : parse_ingress_tstamp_3;
        //VAL_EGRESS_TSTAMP mask MASK_EGRESS_TSTAMP               : parse_egress_tstamp_3;
        //VAL_Q_CONGESTION mask MASK_Q_CONGESTION                 : parse_q_congestion_3;
        //VAL_EGRESS_PORT_TX_UTIL mask MASK_EGRESS_PORT_TX_UTIL   : parse_egressport_tx_util_3;
        // Otherwise check if this is last hop
        LEN_HOPS_4                                              : parse_int_tail;
        // Otherwise start parsing next hop
        VAL_SWITCH_ID mask MASK_SWITCH_ID                       : parse_switch_id_5;
        default			                                        : ingress;
    }
}
parser parse_port_ids_3 {
    extract(int_port_ids_3);
    set_metadata(md_netcope.hop3_vld,1);
    return select(INT_SELECT_CONCAT) {
        // Check if there is any other instruction within the same hop
        //VAL_HOP_LATENCY mask MASK_HOP_LATENCY                   : parse_hop_latency_3;
        VAL_Q_OCCUPANCY mask MASK_Q_OCCUPANCY                   : parse_q_occupancy_3;
        VAL_INGRESS_TSTAMP mask MASK_INGRESS_TSTAMP             : parse_ingress_tstamp_3;
        //VAL_EGRESS_TSTAMP mask MASK_EGRESS_TSTAMP               : parse_egress_tstamp_3;
        //VAL_Q_CONGESTION mask MASK_Q_CONGESTION                 : parse_q_congestion_3;
        //VAL_EGRESS_PORT_TX_UTIL mask MASK_EGRESS_PORT_TX_UTIL   : parse_egressport_tx_util_3;
        // Otherwise check if this is last hop
        LEN_HOPS_4                                              : parse_int_tail;
        // Otherwise start parsing next hop
        VAL_SWITCH_ID mask MASK_SWITCH_ID                       : parse_switch_id_5;
        VAL_PORT_IDS mask MASK_PORT_IDS                         : parse_port_ids_5;
        default			                                        : ingress;
    }
}

parser parse_hop_latency_3 {
    extract(int_hop_latency_3);
    set_metadata(md_netcope.hop3_vld,1);
    return select(INT_SELECT_CONCAT) {
        // Check if there is any other instruction within the same hop
        VAL_Q_OCCUPANCY mask MASK_Q_OCCUPANCY                   : parse_q_occupancy_3;
        VAL_INGRESS_TSTAMP mask MASK_INGRESS_TSTAMP             : parse_ingress_tstamp_3;
        //VAL_EGRESS_TSTAMP mask MASK_EGRESS_TSTAMP               : parse_egress_tstamp_3;
        //VAL_Q_CONGESTION mask MASK_Q_CONGESTION                 : parse_q_congestion_3;
        //VAL_EGRESS_PORT_TX_UTIL mask MASK_EGRESS_PORT_TX_UTIL   : parse_egressport_tx_util_3;
        // Otherwise check if this is last hop
        LEN_HOPS_4                                              : parse_int_tail;
        // Otherwise start parsing next hop
        VAL_SWITCH_ID mask MASK_SWITCH_ID                       : parse_switch_id_5;
        VAL_PORT_IDS mask MASK_PORT_IDS                         : parse_port_ids_5;
        //VAL_HOP_LATENCY mask MASK_HOP_LATENCY                   : parse_hop_latency_5;
        default			                                        : ingress;
    }
}

parser parse_q_occupancy_3 {
    extract(int_q_occupancy_3);
    set_metadata(md_netcope.hop3_vld,1);
    return select(INT_SELECT_CONCAT) {
        // Check if there is any other instruction within the same hop
        VAL_INGRESS_TSTAMP mask MASK_INGRESS_TSTAMP             : parse_ingress_tstamp_3;
        //VAL_EGRESS_TSTAMP mask MASK_EGRESS_TSTAMP               : parse_egress_tstamp_3;
        //VAL_Q_CONGESTION mask MASK_Q_CONGESTION                 : parse_q_congestion_3;
        //VAL_EGRESS_PORT_TX_UTIL mask MASK_EGRESS_PORT_TX_UTIL   : parse_egressport_tx_util_3;
        // Otherwise check if this is last hop
        LEN_HOPS_4                                              : parse_int_tail;
        // Otherwise start parsing next hop
        VAL_SWITCH_ID mask MASK_SWITCH_ID                       : parse_switch_id_5;
        VAL_PORT_IDS mask MASK_PORT_IDS                         : parse_port_ids_5;
        //VAL_HOP_LATENCY mask MASK_HOP_LATENCY                   : parse_hop_latency_5;
        VAL_Q_OCCUPANCY mask MASK_Q_OCCUPANCY                   : parse_q_occupancy_5;
        default			                                        : ingress;
    }
}

parser parse_ingress_tstamp_3 {
    extract(int_ingress_tstamp_3);
    set_metadata(md_netcope.hop3_vld,1);
    return select(INT_SELECT_CONCAT) {
        // Check if there is any other instruction within the same hop
        //VAL_EGRESS_TSTAMP mask MASK_EGRESS_TSTAMP               : parse_egress_tstamp_3;
        //VAL_Q_CONGESTION mask MASK_Q_CONGESTION                 : parse_q_congestion_3;
        //VAL_EGRESS_PORT_TX_UTIL mask MASK_EGRESS_PORT_TX_UTIL   : parse_egressport_tx_util_3;
        // Otherwise check if this is last hop
        LEN_HOPS_4                                              : parse_int_tail;
        // Otherwise start parsing next hop
        VAL_SWITCH_ID mask MASK_SWITCH_ID                       : parse_switch_id_5;
        VAL_PORT_IDS mask MASK_PORT_IDS                         : parse_port_ids_5;
        //VAL_HOP_LATENCY mask MASK_HOP_LATENCY                   : parse_hop_latency_5;
        VAL_Q_OCCUPANCY mask MASK_Q_OCCUPANCY                   : parse_q_occupancy_5;
        VAL_INGRESS_TSTAMP mask MASK_INGRESS_TSTAMP             : parse_ingress_tstamp_5;
        default			                                        : ingress;
    }
}

parser parse_egress_tstamp_3 {
    extract(int_egress_tstamp_3);
    set_metadata(md_netcope.hop3_vld,1);
    return select(INT_SELECT_CONCAT) {
        // Check if there is any other instruction within the same hop
        //VAL_Q_CONGESTION mask MASK_Q_CONGESTION                 : parse_q_congestion_3;
        //VAL_EGRESS_PORT_TX_UTIL mask MASK_EGRESS_PORT_TX_UTIL   : parse_egressport_tx_util_3;
        // Otherwise check if this is last hop
        LEN_HOPS_4                                              : parse_int_tail;
        // Otherwise start parsing next hop
        VAL_SWITCH_ID mask MASK_SWITCH_ID                       : parse_switch_id_5;
        VAL_PORT_IDS mask MASK_PORT_IDS                         : parse_port_ids_5;
        //VAL_HOP_LATENCY mask MASK_HOP_LATENCY                   : parse_hop_latency_5;
        VAL_Q_OCCUPANCY mask MASK_Q_OCCUPANCY                   : parse_q_occupancy_5;
        VAL_INGRESS_TSTAMP mask MASK_INGRESS_TSTAMP             : parse_ingress_tstamp_5;
        //VAL_EGRESS_TSTAMP mask MASK_EGRESS_TSTAMP               : parse_egress_tstamp_5;
        default			                                        : ingress;
    }
}

parser parse_q_congestion_3 {
    extract(int_q_congestion_3);
    set_metadata(md_netcope.hop3_vld,1);
    return select(INT_SELECT_CONCAT) {
        // Check if there is any other instruction within the same hop
        //VAL_EGRESS_PORT_TX_UTIL mask MASK_EGRESS_PORT_TX_UTIL   : parse_egressport_tx_util_3;
        // Otherwise check if this is last hop
        LEN_HOPS_4                                              : parse_int_tail;
        // Otherwise start parsing next hop
        VAL_SWITCH_ID mask MASK_SWITCH_ID                       : parse_switch_id_5;
        VAL_PORT_IDS mask MASK_PORT_IDS                         : parse_port_ids_5;
        //VAL_HOP_LATENCY mask MASK_HOP_LATENCY                   : parse_hop_latency_5;
        VAL_Q_OCCUPANCY mask MASK_Q_OCCUPANCY                   : parse_q_occupancy_5;
        VAL_INGRESS_TSTAMP mask MASK_INGRESS_TSTAMP             : parse_ingress_tstamp_5;
        //VAL_EGRESS_TSTAMP mask MASK_EGRESS_TSTAMP               : parse_egress_tstamp_5;
        //VAL_Q_CONGESTION mask MASK_Q_CONGESTION                 : parse_q_congestion_5;
        default			                                        : ingress;
    }
}

parser parse_egressport_tx_util_3 {
    extract(int_egress_port_tx_util_3);
    set_metadata(md_netcope.hop3_vld,1);
    return select(INT_SELECT_CONCAT) {
        // Check if there is any other instruction within the same hop
        // Otherwise check if this is last hop
        LEN_HOPS_4                                              : parse_int_tail;
        // Otherwise start parsing next hop
        VAL_SWITCH_ID mask MASK_SWITCH_ID                       : parse_switch_id_5;
        VAL_PORT_IDS mask MASK_PORT_IDS                         : parse_port_ids_5;
        //VAL_HOP_LATENCY mask MASK_HOP_LATENCY                   : parse_hop_latency_5;
        VAL_Q_OCCUPANCY mask MASK_Q_OCCUPANCY                   : parse_q_occupancy_5;
        VAL_INGRESS_TSTAMP mask MASK_INGRESS_TSTAMP             : parse_ingress_tstamp_5;
        //VAL_EGRESS_TSTAMP mask MASK_EGRESS_TSTAMP               : parse_egress_tstamp_5;
        //VAL_Q_CONGESTION mask MASK_Q_CONGESTION                 : parse_q_congestion_5;
        //VAL_EGRESS_PORT_TX_UTIL mask MASK_EGRESS_PORT_TX_UTIL   : parse_egressport_tx_util_5;
        default			                                        : ingress;
    }
}


// INT instructions of fifth hop
parser parse_switch_id_4 {
    extract(int_switch_id_4);
    set_metadata(md_netcope.hop4_vld,1);
    return select(INT_SELECT_CONCAT) {
        // Check if there is any other instruction within the same hop
        VAL_PORT_IDS mask MASK_PORT_IDS                         : parse_port_ids_4;
        //VAL_HOP_LATENCY mask MASK_HOP_LATENCY                   : parse_hop_latency_4;
        VAL_Q_OCCUPANCY mask MASK_Q_OCCUPANCY                   : parse_q_occupancy_4;
        VAL_INGRESS_TSTAMP mask MASK_INGRESS_TSTAMP             : parse_ingress_tstamp_4;
        //VAL_EGRESS_TSTAMP mask MASK_EGRESS_TSTAMP               : parse_egress_tstamp_4;
        //VAL_Q_CONGESTION mask MASK_Q_CONGESTION                 : parse_q_congestion_4;
        //VAL_EGRESS_PORT_TX_UTIL mask MASK_EGRESS_PORT_TX_UTIL   : parse_egressport_tx_util_4;
        // Otherwise check if this is last hop
        LEN_HOPS_5                                              : parse_int_tail;
        // Otherwise start parsing next hop
        VAL_SWITCH_ID mask MASK_SWITCH_ID                       : parse_switch_id_5;
        default			                                        : ingress;
    }
}
parser parse_port_ids_4 {
    extract(int_port_ids_4);
    set_metadata(md_netcope.hop4_vld,1);
    return select(INT_SELECT_CONCAT) {
        // Check if there is any other instruction within the same hop
        //VAL_HOP_LATENCY mask MASK_HOP_LATENCY                   : parse_hop_latency_4;
        VAL_Q_OCCUPANCY mask MASK_Q_OCCUPANCY                   : parse_q_occupancy_4;
        VAL_INGRESS_TSTAMP mask MASK_INGRESS_TSTAMP             : parse_ingress_tstamp_4;
        //VAL_EGRESS_TSTAMP mask MASK_EGRESS_TSTAMP               : parse_egress_tstamp_4;
        //VAL_Q_CONGESTION mask MASK_Q_CONGESTION                 : parse_q_congestion_4;
        //VAL_EGRESS_PORT_TX_UTIL mask MASK_EGRESS_PORT_TX_UTIL   : parse_egressport_tx_util_4;
        // Otherwise check if this is last hop
        LEN_HOPS_5                                              : parse_int_tail;
        // Otherwise start parsing next hop
        VAL_SWITCH_ID mask MASK_SWITCH_ID                       : parse_switch_id_5;
        VAL_PORT_IDS mask MASK_PORT_IDS                         : parse_port_ids_5;
        default			                                        : ingress;
    }
}

parser parse_hop_latency_4 {
    extract(int_hop_latency_4);
    set_metadata(md_netcope.hop4_vld,1);
    return select(INT_SELECT_CONCAT) {
        // Check if there is any other instruction within the same hop
        VAL_Q_OCCUPANCY mask MASK_Q_OCCUPANCY                   : parse_q_occupancy_4;
        VAL_INGRESS_TSTAMP mask MASK_INGRESS_TSTAMP             : parse_ingress_tstamp_4;
        //VAL_EGRESS_TSTAMP mask MASK_EGRESS_TSTAMP               : parse_egress_tstamp_4;
        //VAL_Q_CONGESTION mask MASK_Q_CONGESTION                 : parse_q_congestion_4;
        //VAL_EGRESS_PORT_TX_UTIL mask MASK_EGRESS_PORT_TX_UTIL   : parse_egressport_tx_util_4;
        // Otherwise check if this is last hop
        LEN_HOPS_5                                              : parse_int_tail;
        // Otherwise start parsing next hop
        VAL_SWITCH_ID mask MASK_SWITCH_ID                       : parse_switch_id_5;
        VAL_PORT_IDS mask MASK_PORT_IDS                         : parse_port_ids_5;
        //VAL_HOP_LATENCY mask MASK_HOP_LATENCY                   : parse_hop_latency_5;
        default			                                        : ingress;
    }
}

parser parse_q_occupancy_4 {
    extract(int_q_occupancy_4);
    set_metadata(md_netcope.hop4_vld,1);
    return select(INT_SELECT_CONCAT) {
        // Check if there is any other instruction within the same hop
        VAL_INGRESS_TSTAMP mask MASK_INGRESS_TSTAMP             : parse_ingress_tstamp_4;
        //VAL_EGRESS_TSTAMP mask MASK_EGRESS_TSTAMP               : parse_egress_tstamp_4;
        //VAL_Q_CONGESTION mask MASK_Q_CONGESTION                 : parse_q_congestion_4;
        //VAL_EGRESS_PORT_TX_UTIL mask MASK_EGRESS_PORT_TX_UTIL   : parse_egressport_tx_util_4;
        // Otherwise check if this is last hop
        LEN_HOPS_5                                              : parse_int_tail;
        // Otherwise start parsing next hop
        VAL_SWITCH_ID mask MASK_SWITCH_ID                       : parse_switch_id_5;
        VAL_PORT_IDS mask MASK_PORT_IDS                         : parse_port_ids_5;
        //VAL_HOP_LATENCY mask MASK_HOP_LATENCY                   : parse_hop_latency_5;
        VAL_Q_OCCUPANCY mask MASK_Q_OCCUPANCY                   : parse_q_occupancy_5;
        default			                                        : ingress;
    }
}

parser parse_ingress_tstamp_4 {
    extract(int_ingress_tstamp_4);
    set_metadata(md_netcope.hop4_vld,1);
    return select(INT_SELECT_CONCAT) {
        // Check if there is any other instruction within the same hop
        //VAL_EGRESS_TSTAMP mask MASK_EGRESS_TSTAMP               : parse_egress_tstamp_4;
        //VAL_Q_CONGESTION mask MASK_Q_CONGESTION                 : parse_q_congestion_4;
        //VAL_EGRESS_PORT_TX_UTIL mask MASK_EGRESS_PORT_TX_UTIL   : parse_egressport_tx_util_4;
        // Otherwise check if this is last hop
        LEN_HOPS_5                                              : parse_int_tail;
        // Otherwise start parsing next hop
        VAL_SWITCH_ID mask MASK_SWITCH_ID                       : parse_switch_id_5;
        VAL_PORT_IDS mask MASK_PORT_IDS                         : parse_port_ids_5;
        //VAL_HOP_LATENCY mask MASK_HOP_LATENCY                   : parse_hop_latency_5;
        VAL_Q_OCCUPANCY mask MASK_Q_OCCUPANCY                   : parse_q_occupancy_5;
        VAL_INGRESS_TSTAMP mask MASK_INGRESS_TSTAMP             : parse_ingress_tstamp_5;
        default			                                        : ingress;
    }
}

parser parse_egress_tstamp_4 {
    extract(int_egress_tstamp_4);
    set_metadata(md_netcope.hop4_vld,1);
    return select(INT_SELECT_CONCAT) {
        // Check if there is any other instruction within the same hop
        //VAL_Q_CONGESTION mask MASK_Q_CONGESTION                 : parse_q_congestion_4;
        //VAL_EGRESS_PORT_TX_UTIL mask MASK_EGRESS_PORT_TX_UTIL   : parse_egressport_tx_util_4;
        // Otherwise check if this is last hop
        LEN_HOPS_5                                              : parse_int_tail;
        // Otherwise start parsing next hop
        VAL_SWITCH_ID mask MASK_SWITCH_ID                       : parse_switch_id_5;
        VAL_PORT_IDS mask MASK_PORT_IDS                         : parse_port_ids_5;
        //VAL_HOP_LATENCY mask MASK_HOP_LATENCY                   : parse_hop_latency_5;
        VAL_Q_OCCUPANCY mask MASK_Q_OCCUPANCY                   : parse_q_occupancy_5;
        VAL_INGRESS_TSTAMP mask MASK_INGRESS_TSTAMP             : parse_ingress_tstamp_5;
        //VAL_EGRESS_TSTAMP mask MASK_EGRESS_TSTAMP               : parse_egress_tstamp_5;
        default			                                        : ingress;
    }
}

parser parse_q_congestion_4 {
    extract(int_q_congestion_4);
    set_metadata(md_netcope.hop4_vld,1);
    return select(INT_SELECT_CONCAT) {
        // Check if there is any other instruction within the same hop
        //VAL_EGRESS_PORT_TX_UTIL mask MASK_EGRESS_PORT_TX_UTIL   : parse_egressport_tx_util_4;
        // Otherwise check if this is last hop
        LEN_HOPS_5                                              : parse_int_tail;
        // Otherwise start parsing next hop
        VAL_SWITCH_ID mask MASK_SWITCH_ID                       : parse_switch_id_5;
        VAL_PORT_IDS mask MASK_PORT_IDS                         : parse_port_ids_5;
        //VAL_HOP_LATENCY mask MASK_HOP_LATENCY                   : parse_hop_latency_5;
        VAL_Q_OCCUPANCY mask MASK_Q_OCCUPANCY                   : parse_q_occupancy_5;
        VAL_INGRESS_TSTAMP mask MASK_INGRESS_TSTAMP             : parse_ingress_tstamp_5;
        //VAL_EGRESS_TSTAMP mask MASK_EGRESS_TSTAMP               : parse_egress_tstamp_5;
        //VAL_Q_CONGESTION mask MASK_Q_CONGESTION                 : parse_q_congestion_5;
        default			                                        : ingress;
    }
}

parser parse_egressport_tx_util_4 {
    extract(int_egress_port_tx_util_4);
    set_metadata(md_netcope.hop4_vld,1);
    return select(INT_SELECT_CONCAT) {
        // Check if there is any other instruction within the same hop
        // Otherwise check if this is last hop
        LEN_HOPS_5                                              : parse_int_tail;
        // Otherwise start parsing next hop
        VAL_SWITCH_ID mask MASK_SWITCH_ID                       : parse_switch_id_5;
        VAL_PORT_IDS mask MASK_PORT_IDS                         : parse_port_ids_5;
        //VAL_HOP_LATENCY mask MASK_HOP_LATENCY                   : parse_hop_latency_5;
        VAL_Q_OCCUPANCY mask MASK_Q_OCCUPANCY                   : parse_q_occupancy_5;
        VAL_INGRESS_TSTAMP mask MASK_INGRESS_TSTAMP             : parse_ingress_tstamp_5;
        //VAL_EGRESS_TSTAMP mask MASK_EGRESS_TSTAMP               : parse_egress_tstamp_5;
        //VAL_Q_CONGESTION mask MASK_Q_CONGESTION                 : parse_q_congestion_5;
        //VAL_EGRESS_PORT_TX_UTIL mask MASK_EGRESS_PORT_TX_UTIL   : parse_egressport_tx_util_5;
        default			                                        : ingress;
    }
}



// INT instructions of sixth hop
parser parse_switch_id_5 {
    extract(int_switch_id_5);
    set_metadata(md_netcope.hop5_vld,1);
    return select(INT_SELECT_CONCAT) {
        // Check if there is any other instruction within the same hop
        VAL_PORT_IDS mask MASK_PORT_IDS                         : parse_port_ids_5;
        //VAL_HOP_LATENCY mask MASK_HOP_LATENCY                   : parse_hop_latency_5;
        VAL_Q_OCCUPANCY mask MASK_Q_OCCUPANCY                   : parse_q_occupancy_5;
        VAL_INGRESS_TSTAMP mask MASK_INGRESS_TSTAMP             : parse_ingress_tstamp_5;
        //VAL_EGRESS_TSTAMP mask MASK_EGRESS_TSTAMP               : parse_egress_tstamp_5;
        //VAL_Q_CONGESTION mask MASK_Q_CONGESTION                 : parse_q_congestion_5;
        //VAL_EGRESS_PORT_TX_UTIL mask MASK_EGRESS_PORT_TX_UTIL   : parse_egressport_tx_util_5;
        // Otherwise check if this is last hop
        LEN_HOPS_5                                              : parse_int_tail; // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!! LEN_HOPS_5 is used because hop 4 is skipped
        // Otherwise start parsing next hop
        default			                                        : ingress;
    }
}
parser parse_port_ids_5 {
    extract(int_port_ids_5);
    set_metadata(md_netcope.hop5_vld,1);
    return select(INT_SELECT_CONCAT) {
        // Check if there is any other instruction within the same hop
        //VAL_HOP_LATENCY mask MASK_HOP_LATENCY                   : parse_hop_latency_5;
        VAL_Q_OCCUPANCY mask MASK_Q_OCCUPANCY                   : parse_q_occupancy_5;
        VAL_INGRESS_TSTAMP mask MASK_INGRESS_TSTAMP             : parse_ingress_tstamp_5;
        //VAL_EGRESS_TSTAMP mask MASK_EGRESS_TSTAMP               : parse_egress_tstamp_5;
        //VAL_Q_CONGESTION mask MASK_Q_CONGESTION                 : parse_q_congestion_5;
        //VAL_EGRESS_PORT_TX_UTIL mask MASK_EGRESS_PORT_TX_UTIL   : parse_egressport_tx_util_5;
        // Otherwise check if this is last hop
        LEN_HOPS_5                                              : parse_int_tail; // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!! LEN_HOPS_5 is used because hop 4 is skipped
        // Otherwise start parsing next hop
        default			                                        : ingress;
    }
}

parser parse_hop_latency_5 {
    extract(int_hop_latency_5);
    set_metadata(md_netcope.hop5_vld,1);
    return select(INT_SELECT_CONCAT) {
        // Check if there is any other instruction within the same hop
        VAL_Q_OCCUPANCY mask MASK_Q_OCCUPANCY                   : parse_q_occupancy_5;
        VAL_INGRESS_TSTAMP mask MASK_INGRESS_TSTAMP             : parse_ingress_tstamp_5;
        //VAL_EGRESS_TSTAMP mask MASK_EGRESS_TSTAMP               : parse_egress_tstamp_5;
        //VAL_Q_CONGESTION mask MASK_Q_CONGESTION                 : parse_q_congestion_5;
        //VAL_EGRESS_PORT_TX_UTIL mask MASK_EGRESS_PORT_TX_UTIL   : parse_egressport_tx_util_5;
        // Otherwise check if this is last hop
        LEN_HOPS_5                                              : parse_int_tail; // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!! LEN_HOPS_5 is used because hop 4 is skipped
        // Otherwise start parsing next hop
        default			                                        : ingress;
    }
}

parser parse_q_occupancy_5 {
    extract(int_q_occupancy_5);
    set_metadata(md_netcope.hop5_vld,1);
    return select(INT_SELECT_CONCAT) {
        // Check if there is any other instruction within the same hop
        VAL_INGRESS_TSTAMP mask MASK_INGRESS_TSTAMP             : parse_ingress_tstamp_5;
        VAL_EGRESS_TSTAMP mask MASK_EGRESS_TSTAMP               : parse_egress_tstamp_5;
        //VAL_Q_CONGESTION mask MASK_Q_CONGESTION                 : parse_q_congestion_5;
        //VAL_EGRESS_PORT_TX_UTIL mask MASK_EGRESS_PORT_TX_UTIL   : parse_egressport_tx_util_5;
        // Otherwise check if this is last hop
        LEN_HOPS_5                                              : parse_int_tail; // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!! LEN_HOPS_5 is used because hop 4 is skipped
        // Otherwise start parsing next hop
        default			                                        : ingress;
    }
}

parser parse_ingress_tstamp_5 {
    extract(int_ingress_tstamp_5);
    set_metadata(md_netcope.hop5_vld,1);
    return select(INT_SELECT_CONCAT) {
        // Check if there is any other instruction within the same hop
        VAL_EGRESS_TSTAMP mask MASK_EGRESS_TSTAMP               : parse_egress_tstamp_5;
        //VAL_Q_CONGESTION mask MASK_Q_CONGESTION                 : parse_q_congestion_5;
        //VAL_EGRESS_PORT_TX_UTIL mask MASK_EGRESS_PORT_TX_UTIL   : parse_egressport_tx_util_5;
        // Otherwise check if this is last hop
        LEN_HOPS_5                                              : parse_int_tail; // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!! LEN_HOPS_5 is used because hop 4 is skipped
        // Otherwise start parsing next hop
        default			                                        : ingress;
    }
}

parser parse_egress_tstamp_5 {
    extract(int_egress_tstamp_5);
    set_metadata(md_netcope.hop5_vld,1);
    return select(INT_SELECT_CONCAT) {
        // Check if there is any other instruction within the same hop
        //VAL_Q_CONGESTION mask MASK_Q_CONGESTION                 : parse_q_congestion_5;
        //VAL_EGRESS_PORT_TX_UTIL mask MASK_EGRESS_PORT_TX_UTIL   : parse_egressport_tx_util_5;
        // Otherwise check if this is last hop
        LEN_HOPS_5                                              : parse_int_tail; // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!! LEN_HOPS_5 is used because hop 4 is skipped
        // Otherwise start parsing next hop
        default			                                        : ingress;
    }
}

parser parse_q_congestion_5 {
    extract(int_q_congestion_5);
    set_metadata(md_netcope.hop5_vld,1);
    return select(INT_SELECT_CONCAT) {
        // Check if there is any other instruction within the same hop
        //VAL_EGRESS_PORT_TX_UTIL mask MASK_EGRESS_PORT_TX_UTIL   : parse_egressport_tx_util_5;
        // Otherwise check if this is last hop
        LEN_HOPS_5                                              : parse_int_tail; // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!! LEN_HOPS_5 is used because hop 4 is skipped
        // Otherwise start parsing next hop
        default			                                        : ingress;
    }
}

parser parse_egressport_tx_util_5 {
    extract(int_egress_port_tx_util_5);
    set_metadata(md_netcope.hop5_vld,1);
    return select(INT_SELECT_CONCAT) {
        // Check if there is any other instruction within the same hop
        // Otherwise check if this is last hop
        LEN_HOPS_5                                              : parse_int_tail; // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!! LEN_HOPS_5 is used because hop 4 is skipped
        // Otherwise start parsing next hop
        default			                                        : ingress;
    }
}

parser parse_int_tail {
    extract(int_tail);
    set_metadata(md_netcope.valid_int,1);
    return ingress;
}
