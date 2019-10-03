//
// parser.p4: Parser definitions of Netcope P4 INT source & transit processing example.
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
//header tcp_t                        enc_tcp;
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

//metadata  standard_metadata_t           standard_metadata;

// Instances of metadata =======================================================
metadata netcope_metadata_t         md_netcope;
metadata internal_metadata_t        internal_metadata;
metadata int_meta_t                 int_meta;

// Parse graph =================================================================
// Start
parser start {
    set_metadata(md_netcope.valid_int,0);
    set_metadata(md_netcope.hop0_vld,0);
    set_metadata(md_netcope.hop1_vld,0);
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

// TCP
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
        VAL_EGRESS_TSTAMP mask MASK_EGRESS_TSTAMP               : parse_egress_tstamp_0;
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
        VAL_EGRESS_TSTAMP mask MASK_EGRESS_TSTAMP               : parse_egress_tstamp_0;
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
        VAL_EGRESS_TSTAMP mask MASK_EGRESS_TSTAMP               : parse_egress_tstamp_0;
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
        VAL_EGRESS_TSTAMP mask MASK_EGRESS_TSTAMP               : parse_egress_tstamp_0;
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
        VAL_EGRESS_TSTAMP mask MASK_EGRESS_TSTAMP               : parse_egress_tstamp_0;
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
        VAL_EGRESS_TSTAMP mask MASK_EGRESS_TSTAMP               : parse_egress_tstamp_0;
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
        VAL_EGRESS_TSTAMP mask MASK_EGRESS_TSTAMP               : parse_egress_tstamp_1;
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
        VAL_EGRESS_TSTAMP mask MASK_EGRESS_TSTAMP               : parse_egress_tstamp_1;
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
        VAL_EGRESS_TSTAMP mask MASK_EGRESS_TSTAMP               : parse_egress_tstamp_1;
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
        VAL_EGRESS_TSTAMP mask MASK_EGRESS_TSTAMP               : parse_egress_tstamp_1;
        //VAL_Q_CONGESTION mask MASK_Q_CONGESTION                 : parse_q_congestion_1;
        //VAL_EGRESS_PORT_TX_UTIL mask MASK_EGRESS_PORT_TX_UTIL   : parse_egressport_tx_util_1;
        // Otherwise check if this is last hop
        LEN_HOPS_2                                              : parse_int_tail;
        // Otherwise start parsing next hop
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
        VAL_EGRESS_TSTAMP mask MASK_EGRESS_TSTAMP               : parse_egress_tstamp_1;
        //VAL_Q_CONGESTION mask MASK_Q_CONGESTION                 : parse_q_congestion_1;
        //VAL_EGRESS_PORT_TX_UTIL mask MASK_EGRESS_PORT_TX_UTIL   : parse_egressport_tx_util_1;
        // Otherwise check if this is last hop
        LEN_HOPS_2                                              : parse_int_tail;
        // Otherwise start parsing next hop
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
        VAL_EGRESS_TSTAMP mask MASK_EGRESS_TSTAMP               : parse_egress_tstamp_1;
        //VAL_Q_CONGESTION mask MASK_Q_CONGESTION                 : parse_q_congestion_1;
        //VAL_EGRESS_PORT_TX_UTIL mask MASK_EGRESS_PORT_TX_UTIL   : parse_egressport_tx_util_1;
        // Otherwise check if this is last hop
        LEN_HOPS_2                                              : parse_int_tail;
        // Otherwise start parsing next hop
        default			                                        : ingress;
    }
}

parser parse_q_occupancy_1 {
    extract(int_q_occupancy_1);
    set_metadata(md_netcope.hop1_vld,1);
    return select(INT_SELECT_CONCAT) {
        // Check if there is any other instruction within the same hop
        VAL_INGRESS_TSTAMP mask MASK_INGRESS_TSTAMP             : parse_ingress_tstamp_1;
        VAL_EGRESS_TSTAMP mask MASK_EGRESS_TSTAMP               : parse_egress_tstamp_1;
        //VAL_Q_CONGESTION mask MASK_Q_CONGESTION                 : parse_q_congestion_1;
        //VAL_EGRESS_PORT_TX_UTIL mask MASK_EGRESS_PORT_TX_UTIL   : parse_egressport_tx_util_1;
        // Otherwise check if this is last hop
        LEN_HOPS_2                                              : parse_int_tail;
        // Otherwise start parsing next hop
        default			                                        : ingress;
    }
}

parser parse_ingress_tstamp_1 {
    extract(int_ingress_tstamp_1);
    set_metadata(md_netcope.hop1_vld,1);
    return select(INT_SELECT_CONCAT) {
        // Check if there is any other instruction within the same hop
        VAL_EGRESS_TSTAMP mask MASK_EGRESS_TSTAMP               : parse_egress_tstamp_1;
        //VAL_Q_CONGESTION mask MASK_Q_CONGESTION                 : parse_q_congestion_1;
        //VAL_EGRESS_PORT_TX_UTIL mask MASK_EGRESS_PORT_TX_UTIL   : parse_egressport_tx_util_1;
        // Otherwise check if this is last hop
        LEN_HOPS_2                                              : parse_int_tail;
        // Otherwise start parsing next hop
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
        default			                                        : ingress;
    }
}

parser parse_int_tail {
    extract(int_tail);
    set_metadata(md_netcope.valid_int,1);
    return ingress;
}
