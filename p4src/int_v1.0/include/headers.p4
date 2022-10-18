/*
 * Copyright 2020-2021 PSNC, FBK
 *
 * Author: Damian Parniewicz, Damu Ding
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

#define PKT_INSTANCE_TYPE_NORMAL 0
#define PKT_INSTANCE_TYPE_INGRESS_CLONE 1
#define PKT_INSTANCE_TYPE_EGRESS_CLONE 2
#define PKT_INSTANCE_TYPE_COALESCED 3
#define PKT_INSTANCE_TYPE_INGRESS_RECIRC 4
#define PKT_INSTANCE_TYPE_REPLICATION 5
#define PKT_INSTANCE_TYPE_RESUBMIT 6

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

const bit<6> IPv4_DSCP_INT = 0x20;   // indicates an INT header in the packet
const bit<16> INT_SHIM_HEADER_LEN_BYTES = 4;
const bit<8> INT_TYPE_HOP_BY_HOP = 1;

header intl4_shim_t {
    bit<8> int_type;
    bit<8> rsvd1;
    bit<8> len;    // the length of all INT headers in 4-byte words
    bit<6> dscp;  // copy DSCP here
    bit<2> rsvd3;
}

const bit<16> INT_HEADER_LEN_BYTES = 8;
const bit<4> INT_VERSION = 1;

header int_header_t {
    bit<4>  ver;
    bit<2>  rep;
    bit<1>  c;
    bit<1>  e;
    bit<1>  m;
    bit<7>  rsvd1;
    bit<3>  rsvd2;
    bit<5>  hop_metadata_len;   // the length of the metadata added by a single INT node (4-byte words)
    bit<8>  remaining_hop_cnt;  // how many switches can still add INT metadata
    bit<16> instruction_mask;
    bit<8> seq;
    bit<8> rsvd3;
}

const bit<16> INT_ALL_HEADER_LEN_BYTES = INT_SHIM_HEADER_LEN_BYTES + INT_HEADER_LEN_BYTES;

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

header int_q_occupancy_t {
    bit<8>  q_id;
    bit<24> q_occupancy;
}

header int_ingress_tstamp_t {
    bit<64> ingress_tstamp;
}

header int_egress_tstamp_t {
    bit<64> egress_tstamp;
}

header int_level2_port_ids_t {
    bit<16> ingress_port_id;
    bit<16> egress_port_id;
}

header int_egress_port_tx_util_t {
    bit<32> egress_port_tx_util;
}


const bit<4> INT_REPORT_HEADER_LEN_WORDS = 4;
const bit<4> INT_REPORT_VERSION = 1;

header int_report_fixed_header_t {
    bit<4> ver;
    bit<4> len;
    bit<3> nprot;
    bit<5> rep_md_bits_high; // Split rep_md_bits to align to word boundaries
    bit<1> rep_md_bits_low;
    bit<6> reserved;
    bit<1> d;
    bit<1> q;
    bit<1> f;
    bit<6> hw_id;
    bit<32> switch_id;
    bit<32> seq_num;
    bit<32> ingress_tstamp;
}

#ifdef BMV2
struct int_metadata_t {
    bit<1>  source;    // is INT source functionality enabled
    bit<1>  sink;        // is INT sink functionality enabled
    bit<32> switch_id;  // INT switch id is configured by network controller
    bit<16> insert_byte_cnt;  // counter of inserted INT bytes
    bit<8>  int_hdr_word_len;  // counter of inserted INT words
    bit<1>  remove_int;           // indicator that all INT headers and data must be removed at egress for the processed packet 
    bit<16> sink_reporting_port;    // on which port INT reports must be send to INT collector
    bit<64> ingress_tstamp;   // pass ingress timestamp from Ingress pipeline to Egress pipeline
    bit<16> ingress_port;  // pass ingress port from Ingress pipeline to Egress pipeline 
}
#elif TOFINO
// in the header of tofino, the metadata should be a multiple of 8 bits.
header int_metadata_t {
    bit<8> mirror_type; //at the top to act as common header
    @flexible MirrorId_t session_ID;
    bit<4>  source;    // is INT source functionality enabled
    bit<4>  sink;        // is INT sink functionality enabled
    bit<32> switch_id;  // INT switch id is configured by network controller
    bit<16> insert_byte_cnt;  // counter of inserted INT bytes
    bit<8>  int_hdr_word_len;  // counter of inserted INT words
    bit<8>  remove_int;           // indicator that all INT headers and data must be removed at egress for the processed packet
    bit<16> sink_reporting_port;    // on which port INT reports must be send to INT collector
    bit<48> ingress_tstamp;   // pass ingress timestamp from Ingress pipeline to Egress pipeline
    bit<16> ingress_port;  // pass ingress port from Ingress pipeline to Egress pipeline
/*    bit<8> instance_type;*/
}

// Header needed to discern packet type - regular or mirrored clone - in the egress deparser
header mirror_h{
    bit<8> mirror_type;
    bit<48> ingress_tstamp;
    bit<16> ingress_port;  
}
#endif

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
    int_metadata_t       int_metadata;
    intl4_shim_t         int_shim;
    layer34_metadata_t   layer34_metadata;
#ifdef TOFINO
    bit<16>              int_len_bytes;
    mirror_h             mirror_md;
#endif
}

header int_data_t {
    // Enough room for previous 4 nodes worth of data
    varbit<1600> data;
}


struct headers {
    // INT report headers
    ethernet_t                report_ethernet;
    ipv4_t                    report_ipv4;
    udp_t                     report_udp;
    int_report_fixed_header_t report_fixed_header;
    
    // normal headers
    ethernet_t                ethernet;
    ipv4_t                    ipv4;
    tcp_t                     tcp;
    udp_t                     udp;

    // INT headers
    intl4_shim_t              int_shim;
    int_header_t              int_header;
  
    // local INT node metadata
    int_egress_port_tx_util_t int_egress_port_tx_util;
    int_egress_tstamp_t       int_egress_tstamp;
    int_hop_latency_t         int_hop_latency;
    int_ingress_tstamp_t      int_ingress_tstamp;
    int_port_ids_t            int_port_ids;
    int_level2_port_ids_t     int_level2_port_ids;
    int_q_occupancy_t         int_q_occupancy;
    int_switch_id_t           int_switch_id;

    // INT metadata of previous nodes
    int_data_t                int_data;
}


#endif
