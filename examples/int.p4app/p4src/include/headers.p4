//#include <core.p4>
//#include <v1model.p4>

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

header intl4_shim_t {
    bit<8> int_type;
    bit<8> rsvd1;
    bit<8> len;
    bit<6> dscp;
    bit<2> rsvd2;
}

header int_header_t {
    bit<4> ver;
    bit<2> rep;
    bit<1> c;
    bit<1> e;
    bit<1> m;
    bit<7> rsvd1;
    bit<3> rsvd2;
    bit<5> hop_metadata_len;
    bit<8> remaining_hop_cnt;
    bit<16> instruction_mask;
    bit<16> rsvd3;
}

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
    bit<32> ingress_tstamp;
}

header int_egress_tstamp_t {
    bit<32> egress_tstamp;
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
    @name(".int_metadata") 
    int_metadata_t  int_metadata;
    @name(".intrinsic_metadata") 
    intrinsic_metadata_t intrinsic_metadata;
    @name(".layer34_metadata") 
    layer34_metadata_t   layer34_metadata;
}


struct headers {
    @name(".ethernet") 
    ethernet_t                ethernet;
    @name(".ipv4") 
    ipv4_t                    ipv4;
    @name(".tcp") 
    tcp_t                     tcp;
    @name(".udp") 
    udp_t                     udp;

    @name(".enc_ipv4") 
    ipv4_t                    enc_ipv4;
    @name(".enc_udp") 
    udp_t                     enc_udp;

    @name(".gtp") 
    gtp_start_t               gtp;

    @name(".int_shim") 
    intl4_shim_t              int_shim;
    @name(".int_header") 
    int_header_t         int_header;

    @name(".int_egress_port_tx_util") 
    int_egress_port_tx_util_t int_egress_port_tx_util;
    @name(".int_egress_tstamp") 
    int_egress_tstamp_t       int_egress_tstamp;
    @name(".int_hop_latency") 
    int_hop_latency_t         int_hop_latency;
    @name(".int_ingress_tstamp") 
    int_ingress_tstamp_t      int_ingress_tstamp;

    @name(".int_port_ids") 
    int_port_ids_t            int_port_ids; 	
    @name(".int_q_congestion") 
    int_q_congestion_t        int_q_congestion;
    @name(".int_q_occupancy") 
    int_q_occupancy_t         int_q_occupancy;
    @name(".int_switch_id") 
    int_switch_id_t           int_switch_id;
}


#endif
