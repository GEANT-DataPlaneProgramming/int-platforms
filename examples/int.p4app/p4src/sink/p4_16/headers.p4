#include <core.p4>
#include <v1model.p4>
struct internal_metadata_t {
    bit<6>  dscp;
    bit<10> INTlenB;
}

struct netcope_metadata_t {
    bit<1>  valid_int;
    bit<1>  hop0_vld;
    bit<1>  hop1_vld;
    bit<1>  hop2_vld;
    bit<1>  hop3_vld;
    bit<1>  hop4_vld;
    bit<1>  hop5_vld;
    bit<32> IPsrc;
    bit<32> IPdst;
    bit<8>  IPver;
    bit<16> L4src;
    bit<16> L4dst;
    bit<8>  L4proto;
    bit<16> INTinsmap;
    bit<5>  INTinscnt;
    bit<8>  INTlen;
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

header ethernet_t {
    bit<48> dstAddr;
    bit<48> srcAddr;
    bit<16> etherType;
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

header int_egress_port_tx_util_t {
    bit<32> egress_port_tx_util;
}

header int_egress_tstamp_t {
    bit<32> egress_tstamp;
}

header int_header_v0_5_t {
    bit<4>  ver;
    bit<2>  rep;
    bit<1>  c;
    bit<1>  e;
    bit<3>  rsvd1;
    bit<5>  ins_cnt;
    bit<8>  max_hop_count;
    bit<8>  total_hop_count;
    bit<16> instruction_map;
    bit<16> rsvd2;
}

header int_hop_latency_t {
    bit<32> hop_latency;
}

header int_ingress_tstamp_t {
    bit<32> ingress_tstamp;
    bit<32> egress_tstamp;
}

header int_port_ids_t {
    bit<16> ingress_port_id;
    bit<16> egress_port_id;
}

header int_q_congestion_t {
    bit<8>  q_id;
    bit<24> q_congestion;
}

header int_q_occupancy_t {
    bit<8>  q_id;
    bit<24> q_occupancy;
}

header intl4_shim_t {
    bit<8> int_type;
    bit<8> rsvd1;
    bit<8> len;
    bit<8> rsvd2;
}

header int_switch_id_t {
    bit<32> switch_id;
}

header intl4_tail_t {
    bit<8>  next_proto;
    bit<16> dest_port;
    bit<8>  dscp;
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

struct metadata {
    @name(".internal_metadata") 
    internal_metadata_t internal_metadata;
    @name(".md_netcope") 
    netcope_metadata_t  md_netcope;
}

struct headers {
    @name(".enc_ipv4") 
    ipv4_t                    enc_ipv4;
    @name(".enc_udp") 
    udp_t                     enc_udp;
    @name(".ethernet") 
    ethernet_t                ethernet;
    @name(".gtp") 
    gtp_start_t               gtp;
    @name(".int_egress_port_tx_util_0") 
    int_egress_port_tx_util_t int_egress_port_tx_util_0;
    @name(".int_egress_port_tx_util_1") 
    int_egress_port_tx_util_t int_egress_port_tx_util_1;
    @name(".int_egress_port_tx_util_2") 
    int_egress_port_tx_util_t int_egress_port_tx_util_2;
    @name(".int_egress_port_tx_util_3") 
    int_egress_port_tx_util_t int_egress_port_tx_util_3;
    @name(".int_egress_port_tx_util_4") 
    int_egress_port_tx_util_t int_egress_port_tx_util_4;
    @name(".int_egress_port_tx_util_5") 
    int_egress_port_tx_util_t int_egress_port_tx_util_5;
    @name(".int_egress_tstamp_0") 
    int_egress_tstamp_t       int_egress_tstamp_0;
    @name(".int_egress_tstamp_1") 
    int_egress_tstamp_t       int_egress_tstamp_1;
    @name(".int_egress_tstamp_2") 
    int_egress_tstamp_t       int_egress_tstamp_2;
    @name(".int_egress_tstamp_3") 
    int_egress_tstamp_t       int_egress_tstamp_3;
    @name(".int_egress_tstamp_4") 
    int_egress_tstamp_t       int_egress_tstamp_4;
    @name(".int_egress_tstamp_5") 
    int_egress_tstamp_t       int_egress_tstamp_5;
    @name(".int_header") 
    int_header_v0_5_t         int_header;
    @name(".int_hop_latency_0") 
    int_hop_latency_t         int_hop_latency_0;
    @name(".int_hop_latency_1") 
    int_hop_latency_t         int_hop_latency_1;
    @name(".int_hop_latency_2") 
    int_hop_latency_t         int_hop_latency_2;
    @name(".int_hop_latency_3") 
    int_hop_latency_t         int_hop_latency_3;
    @name(".int_hop_latency_4") 
    int_hop_latency_t         int_hop_latency_4;
    @name(".int_hop_latency_5") 
    int_hop_latency_t         int_hop_latency_5;
    @name(".int_ingress_tstamp_0") 
    int_ingress_tstamp_t      int_ingress_tstamp_0;
    @name(".int_ingress_tstamp_1") 
    int_ingress_tstamp_t      int_ingress_tstamp_1;
    @name(".int_ingress_tstamp_2") 
    int_ingress_tstamp_t      int_ingress_tstamp_2;
    @name(".int_ingress_tstamp_3") 
    int_ingress_tstamp_t      int_ingress_tstamp_3;
    @name(".int_ingress_tstamp_4") 
    int_ingress_tstamp_t      int_ingress_tstamp_4;
    @name(".int_ingress_tstamp_5") 
    int_ingress_tstamp_t      int_ingress_tstamp_5;
    @name(".int_port_ids_0") 
    int_port_ids_t            int_port_ids_0;
    @name(".int_port_ids_1") 
    int_port_ids_t            int_port_ids_1;
    @name(".int_port_ids_2") 
    int_port_ids_t            int_port_ids_2;
    @name(".int_port_ids_3") 
    int_port_ids_t            int_port_ids_3;
    @name(".int_port_ids_4") 
    int_port_ids_t            int_port_ids_4;
    @name(".int_port_ids_5") 
    int_port_ids_t            int_port_ids_5;
    @name(".int_q_congestion_0") 
    int_q_congestion_t        int_q_congestion_0;
    @name(".int_q_congestion_1") 
    int_q_congestion_t        int_q_congestion_1;
    @name(".int_q_congestion_2") 
    int_q_congestion_t        int_q_congestion_2;
    @name(".int_q_congestion_3") 
    int_q_congestion_t        int_q_congestion_3;
    @name(".int_q_congestion_4") 
    int_q_congestion_t        int_q_congestion_4;
    @name(".int_q_congestion_5") 
    int_q_congestion_t        int_q_congestion_5;
    @name(".int_q_occupancy_0") 
    int_q_occupancy_t         int_q_occupancy_0;
    @name(".int_q_occupancy_1") 
    int_q_occupancy_t         int_q_occupancy_1;
    @name(".int_q_occupancy_2") 
    int_q_occupancy_t         int_q_occupancy_2;
    @name(".int_q_occupancy_3") 
    int_q_occupancy_t         int_q_occupancy_3;
    @name(".int_q_occupancy_4") 
    int_q_occupancy_t         int_q_occupancy_4;
    @name(".int_q_occupancy_5") 
    int_q_occupancy_t         int_q_occupancy_5;
    @name(".int_shim") 
    intl4_shim_t              int_shim;
    @name(".int_switch_id_0") 
    int_switch_id_t           int_switch_id_0;
    @name(".int_switch_id_1") 
    int_switch_id_t           int_switch_id_1;
    @name(".int_switch_id_2") 
    int_switch_id_t           int_switch_id_2;
    @name(".int_switch_id_3") 
    int_switch_id_t           int_switch_id_3;
    @name(".int_switch_id_4") 
    int_switch_id_t           int_switch_id_4;
    @name(".int_switch_id_5") 
    int_switch_id_t           int_switch_id_5;
    @name(".int_tail") 
    intl4_tail_t              int_tail;
    @name(".ipv4") 
    ipv4_t                    ipv4;
    @name(".tcp") 
    tcp_t                     tcp;
    @name(".udp") 
    udp_t                     udp;
}

