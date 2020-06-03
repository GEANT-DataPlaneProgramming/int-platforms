/*
 * Copyright 2020 PSNC
 *
 * Author: Damian Parniewicz
 *
 * Created in the GN4-3 project.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
 
#ifndef _HEADERS_P4_
#define _HEADERS_P4_

header ethernet_t {
    bit<48> dstAddr;
    bit<48> srcAddr;
    bit<16> etherType;
}

header ipv4_t {
    bit<4>  version;
    bit<4>  ihl;
    bit<6>  dscp;
    bit<2>  ecn;
    bit<16> totalLen;
    bit<16> id;
    bit<3>  flags;
    bit<13> fragOffset;
    bit<8>  ttl;
    bit<8>  protocol;
    bit<16> hdrChecksum;
    bit<32> srcAddr;
    bit<32> dstAddr;
}

header udp_t {
    bit<16> srcPort;
    bit<16> dstPort;
    bit<16> len;
    bit<16> csum;
}

header tcp_t {
    bit<16> srcPort;
    bit<16> dstPort;
    bit<32> seqNum;
    bit<32> ackNum;
    bit<4>  dataOffset;
    bit<3>  reserved;
    bit<9>  flags;
    bit<16> winSize;
    bit<16> csum;
    bit<16> urgPoint;
}

header gtp_start_t {
    bit<3>  version;
    bit<1>  protType;
    bit<1>  reserved;
    bit<3>  flags;
    bit<8>  messageType;
    bit<16> messageLen;
    bit<32> teid;
}

const bit<6> IPv4_DSCP_INT = 0x20;   // indicates that INT header in the packet
const bit<16> INT_SHIM_HEADER_LEN_BYTES = 4;

header intl4_shim_t {
    bit<8> int_type;
    bit<8> rsvd1;
    bit<8> len;
    bit<6> dscp;
    bit<2> rsvd2;
}

const bit<16> INT_HEADER_LEN_BYTES = 8;

header int_header_t {
    bit<2> ver;
    bit<2> rep;
    bit<1> c;
    bit<1> e;
    bit<5> rsvd1;
    bit<5> ins_cnt;  // the number of instructions that are set in the instruction mask
    bit<8> max_hops; // maximum number of hops inserting INT metadata
    bit<8> total_hops; // number of hops that inserted INT metadata
    bit<16> instruction_mask;
    bit<16> rsvd2;
}

// INT tail header for TCP/UDP - 4 bytes
const bit<16> INT_TAIL_HEADER_LEN_BYTES = 4;

header intl4_tail_t {
    bit<8> next_proto;
    bit<16> dest_port;
    bit<2> padding;
    bit<6> dscp;
}

const bit<16> INT_ALL_HEADER_LEN_BYTES = INT_SHIM_HEADER_LEN_BYTES + INT_HEADER_LEN_BYTES + INT_TAIL_HEADER_LEN_BYTES;

header int_switch_id_t {
    bit<32> switch_id;
}

header int_port_ids_t {
    bit<16> ingress_port_id;
    bit<16> egress_port_id;
}

header int_hop_latency_t {
    bit<32> hop_latency;
}

header int_ingress_tstamp_t {
    bit<64> ingress_tstamp;
}

header int_egress_tstamp_t {
    bit<64> egress_tstamp;
}

header int_egress_port_tx_util_t {
    bit<32> egress_port_tx_util;
}

header int_q_congestion_t {
    bit<8>  q_id;
    bit<24> q_congestion;
}

header int_q_occupancy_t {
    bit<8>  q_id;
    bit<24> q_occupancy;
}

struct int_metadata_t {
    bit<1>  source;
    bit<1>  sink;
    bit<32> switch_id;
    bit<16>  insert_byte_cnt;
    bit<8> int_hdr_word_len;
}

struct intrinsic_metadata_t {
    bit<48> ingress_timestamp;
}

struct layer34_metadata_t {
    bit<32> ip_src;
    bit<32> ip_dst;
    bit<8>  ip_ver;
    bit<16> l4_src;
    bit<16> l4_dst;
    bit<8>  l4_proto;
    bit<16> l3_mtu;
    bit<6>  dscp;
}


struct metadata {
    int_metadata_t  int_metadata;
    intrinsic_metadata_t intrinsic_metadata;
    layer34_metadata_t   layer34_metadata;
}


struct headers {
    ethernet_t                ethernet;
    ipv4_t                    ipv4;
    tcp_t                     tcp;
    udp_t                     udp;

    ipv4_t                    enc_ipv4;
    udp_t                     enc_udp;

    gtp_start_t               gtp;

    intl4_shim_t          int_shim;
    int_header_t         int_header;
    intl4_tail_t            int_tail;

    int_egress_port_tx_util_t  int_egress_port_tx_util;
    int_egress_tstamp_t         int_egress_tstamp;
    int_hop_latency_t             int_hop_latency;
    int_ingress_tstamp_t        int_ingress_tstamp;
    int_port_ids_t                  int_port_ids; 
    int_q_congestion_t           int_q_congestion;
    int_q_occupancy_t           int_q_occupancy;
    int_switch_id_t                int_switch_id;
}


#endif
