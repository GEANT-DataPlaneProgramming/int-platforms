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

parser ParserImpl(packet_in packet, out headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @name(".parse_egress_tstamp_0") state parse_egress_tstamp_0 {
        packet.extract(hdr.int_egress_tstamp_0);
        meta.md_netcope.hop0_vld = 1w1;
        transition select(meta.md_netcope.INTinscnt, meta.md_netcope.INTinsmap, meta.md_netcope.INTlen) {
            (5w0x1 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x5 &&& 8w0xff): parse_int_tail;
            (5w0x2 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x6 &&& 8w0xff): parse_int_tail;
            (5w0x3 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x7 &&& 8w0xff): parse_int_tail;
            (5w0x4 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x8 &&& 8w0xff): parse_int_tail;
            (5w0x5 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x9 &&& 8w0xff): parse_int_tail;
            (5w0x6 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xa &&& 8w0xff): parse_int_tail;
            (5w0x7 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xb &&& 8w0xff): parse_int_tail;
            (5w0x8 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xc &&& 8w0xff): parse_int_tail;
            (5w0x0 &&& 5w0x0, 16w0x8000 &&& 16w0x8000, 8w0x0 &&& 8w0x0): parse_switch_id_1;
            (5w0x0 &&& 5w0x0, 16w0x4000 &&& 16w0x4000, 8w0x0 &&& 8w0x0): parse_port_ids_1;
            (5w0x0 &&& 5w0x0, 16w0x1000 &&& 16w0x1000, 8w0x0 &&& 8w0x0): parse_q_occupancy_1;
            (5w0x0 &&& 5w0x0, 16w0x800 &&& 16w0x800, 8w0x0 &&& 8w0x0): parse_ingress_tstamp_1;
            default: accept;
        }
    }
    @name(".parse_egress_tstamp_1") state parse_egress_tstamp_1 {
        packet.extract(hdr.int_egress_tstamp_1);
        meta.md_netcope.hop1_vld = 1w1;
        transition select(meta.md_netcope.INTinscnt, meta.md_netcope.INTinsmap, meta.md_netcope.INTlen) {
            (5w0x1 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x6 &&& 8w0xff): parse_int_tail;
            (5w0x2 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x8 &&& 8w0xff): parse_int_tail;
            (5w0x3 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xa &&& 8w0xff): parse_int_tail;
            (5w0x4 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xc &&& 8w0xff): parse_int_tail;
            (5w0x5 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xe &&& 8w0xff): parse_int_tail;
            (5w0x6 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x10 &&& 8w0xff): parse_int_tail;
            (5w0x7 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x12 &&& 8w0xff): parse_int_tail;
            (5w0x8 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x14 &&& 8w0xff): parse_int_tail;
            (5w0x0 &&& 5w0x0, 16w0x8000 &&& 16w0x8000, 8w0x0 &&& 8w0x0): parse_switch_id_2;
            (5w0x0 &&& 5w0x0, 16w0x4000 &&& 16w0x4000, 8w0x0 &&& 8w0x0): parse_port_ids_2;
            (5w0x0 &&& 5w0x0, 16w0x1000 &&& 16w0x1000, 8w0x0 &&& 8w0x0): parse_q_occupancy_2;
            (5w0x0 &&& 5w0x0, 16w0x800 &&& 16w0x800, 8w0x0 &&& 8w0x0): parse_ingress_tstamp_2;
            default: accept;
        }
    }
    @name(".parse_egress_tstamp_2") state parse_egress_tstamp_2 {
        packet.extract(hdr.int_egress_tstamp_2);
        meta.md_netcope.hop2_vld = 1w1;
        transition select(meta.md_netcope.INTinscnt, meta.md_netcope.INTinsmap, meta.md_netcope.INTlen) {
            (5w0x1 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x7 &&& 8w0xff): parse_int_tail;
            (5w0x2 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xa &&& 8w0xff): parse_int_tail;
            (5w0x3 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xd &&& 8w0xff): parse_int_tail;
            (5w0x4 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x10 &&& 8w0xff): parse_int_tail;
            (5w0x5 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x13 &&& 8w0xff): parse_int_tail;
            (5w0x6 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x16 &&& 8w0xff): parse_int_tail;
            (5w0x7 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x19 &&& 8w0xff): parse_int_tail;
            (5w0x8 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x1c &&& 8w0xff): parse_int_tail;
            (5w0x0 &&& 5w0x0, 16w0x8000 &&& 16w0x8000, 8w0x0 &&& 8w0x0): parse_switch_id_3;
            (5w0x0 &&& 5w0x0, 16w0x4000 &&& 16w0x4000, 8w0x0 &&& 8w0x0): parse_port_ids_3;
            (5w0x0 &&& 5w0x0, 16w0x1000 &&& 16w0x1000, 8w0x0 &&& 8w0x0): parse_q_occupancy_3;
            (5w0x0 &&& 5w0x0, 16w0x800 &&& 16w0x800, 8w0x0 &&& 8w0x0): parse_ingress_tstamp_3;
            default: accept;
        }
    }
    @name(".parse_egress_tstamp_3") state parse_egress_tstamp_3 {
        packet.extract(hdr.int_egress_tstamp_3);
        meta.md_netcope.hop3_vld = 1w1;
        transition select(meta.md_netcope.INTinscnt, meta.md_netcope.INTinsmap, meta.md_netcope.INTlen) {
            (5w0x1 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x8 &&& 8w0xff): parse_int_tail;
            (5w0x2 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xc &&& 8w0xff): parse_int_tail;
            (5w0x3 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x10 &&& 8w0xff): parse_int_tail;
            (5w0x4 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x14 &&& 8w0xff): parse_int_tail;
            (5w0x5 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x18 &&& 8w0xff): parse_int_tail;
            (5w0x6 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x1c &&& 8w0xff): parse_int_tail;
            (5w0x7 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x20 &&& 8w0xff): parse_int_tail;
            (5w0x8 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x24 &&& 8w0xff): parse_int_tail;
            (5w0x0 &&& 5w0x0, 16w0x8000 &&& 16w0x8000, 8w0x0 &&& 8w0x0): parse_switch_id_5;
            (5w0x0 &&& 5w0x0, 16w0x4000 &&& 16w0x4000, 8w0x0 &&& 8w0x0): parse_port_ids_5;
            (5w0x0 &&& 5w0x0, 16w0x1000 &&& 16w0x1000, 8w0x0 &&& 8w0x0): parse_q_occupancy_5;
            (5w0x0 &&& 5w0x0, 16w0x800 &&& 16w0x800, 8w0x0 &&& 8w0x0): parse_ingress_tstamp_5;
            default: accept;
        }
    }
    @name(".parse_egress_tstamp_4") state parse_egress_tstamp_4 {
        packet.extract(hdr.int_egress_tstamp_4);
        meta.md_netcope.hop4_vld = 1w1;
        transition select(meta.md_netcope.INTinscnt, meta.md_netcope.INTinsmap, meta.md_netcope.INTlen) {
            (5w0x1 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x9 &&& 8w0xff): parse_int_tail;
            (5w0x2 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xe &&& 8w0xff): parse_int_tail;
            (5w0x3 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x13 &&& 8w0xff): parse_int_tail;
            (5w0x4 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x18 &&& 8w0xff): parse_int_tail;
            (5w0x5 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x1d &&& 8w0xff): parse_int_tail;
            (5w0x6 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x22 &&& 8w0xff): parse_int_tail;
            (5w0x7 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x27 &&& 8w0xff): parse_int_tail;
            (5w0x8 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x2c &&& 8w0xff): parse_int_tail;
            (5w0x0 &&& 5w0x0, 16w0x8000 &&& 16w0x8000, 8w0x0 &&& 8w0x0): parse_switch_id_5;
            (5w0x0 &&& 5w0x0, 16w0x4000 &&& 16w0x4000, 8w0x0 &&& 8w0x0): parse_port_ids_5;
            (5w0x0 &&& 5w0x0, 16w0x1000 &&& 16w0x1000, 8w0x0 &&& 8w0x0): parse_q_occupancy_5;
            (5w0x0 &&& 5w0x0, 16w0x800 &&& 16w0x800, 8w0x0 &&& 8w0x0): parse_ingress_tstamp_5;
            default: accept;
        }
    }
    @name(".parse_egress_tstamp_5") state parse_egress_tstamp_5 {
        packet.extract(hdr.int_egress_tstamp_5);
        meta.md_netcope.hop5_vld = 1w1;
        transition select(meta.md_netcope.INTinscnt, meta.md_netcope.INTinsmap, meta.md_netcope.INTlen) {
            (5w0x1 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x9 &&& 8w0xff): parse_int_tail;
            (5w0x2 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xe &&& 8w0xff): parse_int_tail;
            (5w0x3 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x13 &&& 8w0xff): parse_int_tail;
            (5w0x4 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x18 &&& 8w0xff): parse_int_tail;
            (5w0x5 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x1d &&& 8w0xff): parse_int_tail;
            (5w0x6 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x22 &&& 8w0xff): parse_int_tail;
            (5w0x7 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x27 &&& 8w0xff): parse_int_tail;
            (5w0x8 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x2c &&& 8w0xff): parse_int_tail;
            default: accept;
        }
    }
    @name(".parse_egressport_tx_util_0") state parse_egressport_tx_util_0 {
        packet.extract(hdr.int_egress_port_tx_util_0);
        meta.md_netcope.hop0_vld = 1w1;
        transition select(meta.md_netcope.INTinscnt, meta.md_netcope.INTinsmap, meta.md_netcope.INTlen) {
            (5w0x1 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x5 &&& 8w0xff): parse_int_tail;
            (5w0x2 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x6 &&& 8w0xff): parse_int_tail;
            (5w0x3 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x7 &&& 8w0xff): parse_int_tail;
            (5w0x4 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x8 &&& 8w0xff): parse_int_tail;
            (5w0x5 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x9 &&& 8w0xff): parse_int_tail;
            (5w0x6 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xa &&& 8w0xff): parse_int_tail;
            (5w0x7 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xb &&& 8w0xff): parse_int_tail;
            (5w0x8 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xc &&& 8w0xff): parse_int_tail;
            (5w0x0 &&& 5w0x0, 16w0x8000 &&& 16w0x8000, 8w0x0 &&& 8w0x0): parse_switch_id_1;
            (5w0x0 &&& 5w0x0, 16w0x4000 &&& 16w0x4000, 8w0x0 &&& 8w0x0): parse_port_ids_1;
            (5w0x0 &&& 5w0x0, 16w0x1000 &&& 16w0x1000, 8w0x0 &&& 8w0x0): parse_q_occupancy_1;
            (5w0x0 &&& 5w0x0, 16w0x800 &&& 16w0x800, 8w0x0 &&& 8w0x0): parse_ingress_tstamp_1;
            default: accept;
        }
    }
    @name(".parse_egressport_tx_util_1") state parse_egressport_tx_util_1 {
        packet.extract(hdr.int_egress_port_tx_util_1);
        meta.md_netcope.hop1_vld = 1w1;
        transition select(meta.md_netcope.INTinscnt, meta.md_netcope.INTinsmap, meta.md_netcope.INTlen) {
            (5w0x1 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x6 &&& 8w0xff): parse_int_tail;
            (5w0x2 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x8 &&& 8w0xff): parse_int_tail;
            (5w0x3 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xa &&& 8w0xff): parse_int_tail;
            (5w0x4 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xc &&& 8w0xff): parse_int_tail;
            (5w0x5 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xe &&& 8w0xff): parse_int_tail;
            (5w0x6 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x10 &&& 8w0xff): parse_int_tail;
            (5w0x7 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x12 &&& 8w0xff): parse_int_tail;
            (5w0x8 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x14 &&& 8w0xff): parse_int_tail;
            (5w0x0 &&& 5w0x0, 16w0x8000 &&& 16w0x8000, 8w0x0 &&& 8w0x0): parse_switch_id_2;
            (5w0x0 &&& 5w0x0, 16w0x4000 &&& 16w0x4000, 8w0x0 &&& 8w0x0): parse_port_ids_2;
            (5w0x0 &&& 5w0x0, 16w0x1000 &&& 16w0x1000, 8w0x0 &&& 8w0x0): parse_q_occupancy_2;
            (5w0x0 &&& 5w0x0, 16w0x800 &&& 16w0x800, 8w0x0 &&& 8w0x0): parse_ingress_tstamp_2;
            default: accept;
        }
    }
    @name(".parse_egressport_tx_util_2") state parse_egressport_tx_util_2 {
        packet.extract(hdr.int_egress_port_tx_util_2);
        meta.md_netcope.hop2_vld = 1w1;
        transition select(meta.md_netcope.INTinscnt, meta.md_netcope.INTinsmap, meta.md_netcope.INTlen) {
            (5w0x1 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x7 &&& 8w0xff): parse_int_tail;
            (5w0x2 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xa &&& 8w0xff): parse_int_tail;
            (5w0x3 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xd &&& 8w0xff): parse_int_tail;
            (5w0x4 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x10 &&& 8w0xff): parse_int_tail;
            (5w0x5 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x13 &&& 8w0xff): parse_int_tail;
            (5w0x6 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x16 &&& 8w0xff): parse_int_tail;
            (5w0x7 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x19 &&& 8w0xff): parse_int_tail;
            (5w0x8 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x1c &&& 8w0xff): parse_int_tail;
            (5w0x0 &&& 5w0x0, 16w0x8000 &&& 16w0x8000, 8w0x0 &&& 8w0x0): parse_switch_id_3;
            (5w0x0 &&& 5w0x0, 16w0x4000 &&& 16w0x4000, 8w0x0 &&& 8w0x0): parse_port_ids_3;
            (5w0x0 &&& 5w0x0, 16w0x1000 &&& 16w0x1000, 8w0x0 &&& 8w0x0): parse_q_occupancy_3;
            (5w0x0 &&& 5w0x0, 16w0x800 &&& 16w0x800, 8w0x0 &&& 8w0x0): parse_ingress_tstamp_3;
            default: accept;
        }
    }
    @name(".parse_egressport_tx_util_3") state parse_egressport_tx_util_3 {
        packet.extract(hdr.int_egress_port_tx_util_3);
        meta.md_netcope.hop3_vld = 1w1;
        transition select(meta.md_netcope.INTinscnt, meta.md_netcope.INTinsmap, meta.md_netcope.INTlen) {
            (5w0x1 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x8 &&& 8w0xff): parse_int_tail;
            (5w0x2 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xc &&& 8w0xff): parse_int_tail;
            (5w0x3 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x10 &&& 8w0xff): parse_int_tail;
            (5w0x4 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x14 &&& 8w0xff): parse_int_tail;
            (5w0x5 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x18 &&& 8w0xff): parse_int_tail;
            (5w0x6 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x1c &&& 8w0xff): parse_int_tail;
            (5w0x7 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x20 &&& 8w0xff): parse_int_tail;
            (5w0x8 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x24 &&& 8w0xff): parse_int_tail;
            (5w0x0 &&& 5w0x0, 16w0x8000 &&& 16w0x8000, 8w0x0 &&& 8w0x0): parse_switch_id_5;
            (5w0x0 &&& 5w0x0, 16w0x4000 &&& 16w0x4000, 8w0x0 &&& 8w0x0): parse_port_ids_5;
            (5w0x0 &&& 5w0x0, 16w0x1000 &&& 16w0x1000, 8w0x0 &&& 8w0x0): parse_q_occupancy_5;
            (5w0x0 &&& 5w0x0, 16w0x800 &&& 16w0x800, 8w0x0 &&& 8w0x0): parse_ingress_tstamp_5;
            default: accept;
        }
    }
    @name(".parse_egressport_tx_util_4") state parse_egressport_tx_util_4 {
        packet.extract(hdr.int_egress_port_tx_util_4);
        meta.md_netcope.hop4_vld = 1w1;
        transition select(meta.md_netcope.INTinscnt, meta.md_netcope.INTinsmap, meta.md_netcope.INTlen) {
            (5w0x1 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x9 &&& 8w0xff): parse_int_tail;
            (5w0x2 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xe &&& 8w0xff): parse_int_tail;
            (5w0x3 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x13 &&& 8w0xff): parse_int_tail;
            (5w0x4 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x18 &&& 8w0xff): parse_int_tail;
            (5w0x5 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x1d &&& 8w0xff): parse_int_tail;
            (5w0x6 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x22 &&& 8w0xff): parse_int_tail;
            (5w0x7 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x27 &&& 8w0xff): parse_int_tail;
            (5w0x8 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x2c &&& 8w0xff): parse_int_tail;
            (5w0x0 &&& 5w0x0, 16w0x8000 &&& 16w0x8000, 8w0x0 &&& 8w0x0): parse_switch_id_5;
            (5w0x0 &&& 5w0x0, 16w0x4000 &&& 16w0x4000, 8w0x0 &&& 8w0x0): parse_port_ids_5;
            (5w0x0 &&& 5w0x0, 16w0x1000 &&& 16w0x1000, 8w0x0 &&& 8w0x0): parse_q_occupancy_5;
            (5w0x0 &&& 5w0x0, 16w0x800 &&& 16w0x800, 8w0x0 &&& 8w0x0): parse_ingress_tstamp_5;
            default: accept;
        }
    }
    @name(".parse_egressport_tx_util_5") state parse_egressport_tx_util_5 {
        packet.extract(hdr.int_egress_port_tx_util_5);
        meta.md_netcope.hop5_vld = 1w1;
        transition select(meta.md_netcope.INTinscnt, meta.md_netcope.INTinsmap, meta.md_netcope.INTlen) {
            (5w0x1 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x9 &&& 8w0xff): parse_int_tail;
            (5w0x2 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xe &&& 8w0xff): parse_int_tail;
            (5w0x3 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x13 &&& 8w0xff): parse_int_tail;
            (5w0x4 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x18 &&& 8w0xff): parse_int_tail;
            (5w0x5 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x1d &&& 8w0xff): parse_int_tail;
            (5w0x6 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x22 &&& 8w0xff): parse_int_tail;
            (5w0x7 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x27 &&& 8w0xff): parse_int_tail;
            (5w0x8 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x2c &&& 8w0xff): parse_int_tail;
            default: accept;
        }
    }
    @name(".parse_enc_ipv4") state parse_enc_ipv4 {
        packet.extract(hdr.enc_ipv4);
        meta.md_netcope.IPsrc = hdr.enc_ipv4.srcAddr;
        meta.md_netcope.IPdst = hdr.enc_ipv4.dstAddr;
        meta.md_netcope.IPver = 8w4;
        meta.internal_metadata.dscp = hdr.enc_ipv4.dscp;
        transition select(hdr.enc_ipv4.protocol) {
            8w0x11: parse_enc_udp;
            8w0x6: parse_tcp;
            default: accept;
        }
    }
    @name(".parse_enc_udp") state parse_enc_udp {
        packet.extract(hdr.enc_udp);
        meta.md_netcope.L4src = hdr.enc_udp.srcPort;
        meta.md_netcope.L4dst = hdr.enc_udp.dstPort;
        meta.md_netcope.L4proto = 8w0x11;
        transition select(meta.internal_metadata.dscp) {
            6w0x1: parse_int_shim;
            default: accept;
        }
    }
    @name(".parse_ethernet") state parse_ethernet {
        packet.extract(hdr.ethernet);
        transition select(hdr.ethernet.etherType) {
            16w0x800: parse_ipv4;
            default: accept;
        }
    }
    @name(".parse_gtp") state parse_gtp {
        packet.extract(hdr.gtp);
        transition select((packet.lookahead<bit<4>>())[3:0]) {
            4w4: parse_enc_ipv4;
            default: accept;
        }
    }
    @name(".parse_hop_latency_0") state parse_hop_latency_0 {
        packet.extract(hdr.int_hop_latency_0);
        meta.md_netcope.hop0_vld = 1w1;
        transition select(meta.md_netcope.INTinscnt, meta.md_netcope.INTinsmap, meta.md_netcope.INTlen) {
            (5w0x0 &&& 5w0x0, 16w0x1000 &&& 16w0x1000, 8w0x0 &&& 8w0x0): parse_q_occupancy_0;
            (5w0x0 &&& 5w0x0, 16w0x800 &&& 16w0x800, 8w0x0 &&& 8w0x0): parse_ingress_tstamp_0;
            (5w0x1 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x5 &&& 8w0xff): parse_int_tail;
            (5w0x2 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x6 &&& 8w0xff): parse_int_tail;
            (5w0x3 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x7 &&& 8w0xff): parse_int_tail;
            (5w0x4 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x8 &&& 8w0xff): parse_int_tail;
            (5w0x5 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x9 &&& 8w0xff): parse_int_tail;
            (5w0x6 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xa &&& 8w0xff): parse_int_tail;
            (5w0x7 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xb &&& 8w0xff): parse_int_tail;
            (5w0x8 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xc &&& 8w0xff): parse_int_tail;
            (5w0x0 &&& 5w0x0, 16w0x8000 &&& 16w0x8000, 8w0x0 &&& 8w0x0): parse_switch_id_1;
            (5w0x0 &&& 5w0x0, 16w0x4000 &&& 16w0x4000, 8w0x0 &&& 8w0x0): parse_port_ids_1;
            default: accept;
        }
    }
    @name(".parse_hop_latency_1") state parse_hop_latency_1 {
        packet.extract(hdr.int_hop_latency_1);
        meta.md_netcope.hop1_vld = 1w1;
        transition select(meta.md_netcope.INTinscnt, meta.md_netcope.INTinsmap, meta.md_netcope.INTlen) {
            (5w0x0 &&& 5w0x0, 16w0x1000 &&& 16w0x1000, 8w0x0 &&& 8w0x0): parse_q_occupancy_1;
            (5w0x0 &&& 5w0x0, 16w0x800 &&& 16w0x800, 8w0x0 &&& 8w0x0): parse_ingress_tstamp_1;
            (5w0x1 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x6 &&& 8w0xff): parse_int_tail;
            (5w0x2 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x8 &&& 8w0xff): parse_int_tail;
            (5w0x3 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xa &&& 8w0xff): parse_int_tail;
            (5w0x4 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xc &&& 8w0xff): parse_int_tail;
            (5w0x5 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xe &&& 8w0xff): parse_int_tail;
            (5w0x6 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x10 &&& 8w0xff): parse_int_tail;
            (5w0x7 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x12 &&& 8w0xff): parse_int_tail;
            (5w0x8 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x14 &&& 8w0xff): parse_int_tail;
            (5w0x0 &&& 5w0x0, 16w0x8000 &&& 16w0x8000, 8w0x0 &&& 8w0x0): parse_switch_id_2;
            (5w0x0 &&& 5w0x0, 16w0x4000 &&& 16w0x4000, 8w0x0 &&& 8w0x0): parse_port_ids_2;
            default: accept;
        }
    }
    @name(".parse_hop_latency_2") state parse_hop_latency_2 {
        packet.extract(hdr.int_hop_latency_2);
        meta.md_netcope.hop2_vld = 1w1;
        transition select(meta.md_netcope.INTinscnt, meta.md_netcope.INTinsmap, meta.md_netcope.INTlen) {
            (5w0x0 &&& 5w0x0, 16w0x1000 &&& 16w0x1000, 8w0x0 &&& 8w0x0): parse_q_occupancy_2;
            (5w0x0 &&& 5w0x0, 16w0x800 &&& 16w0x800, 8w0x0 &&& 8w0x0): parse_ingress_tstamp_2;
            (5w0x1 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x7 &&& 8w0xff): parse_int_tail;
            (5w0x2 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xa &&& 8w0xff): parse_int_tail;
            (5w0x3 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xd &&& 8w0xff): parse_int_tail;
            (5w0x4 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x10 &&& 8w0xff): parse_int_tail;
            (5w0x5 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x13 &&& 8w0xff): parse_int_tail;
            (5w0x6 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x16 &&& 8w0xff): parse_int_tail;
            (5w0x7 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x19 &&& 8w0xff): parse_int_tail;
            (5w0x8 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x1c &&& 8w0xff): parse_int_tail;
            (5w0x0 &&& 5w0x0, 16w0x8000 &&& 16w0x8000, 8w0x0 &&& 8w0x0): parse_switch_id_3;
            (5w0x0 &&& 5w0x0, 16w0x4000 &&& 16w0x4000, 8w0x0 &&& 8w0x0): parse_port_ids_3;
            default: accept;
        }
    }
    @name(".parse_hop_latency_3") state parse_hop_latency_3 {
        packet.extract(hdr.int_hop_latency_3);
        meta.md_netcope.hop3_vld = 1w1;
        transition select(meta.md_netcope.INTinscnt, meta.md_netcope.INTinsmap, meta.md_netcope.INTlen) {
            (5w0x0 &&& 5w0x0, 16w0x1000 &&& 16w0x1000, 8w0x0 &&& 8w0x0): parse_q_occupancy_3;
            (5w0x0 &&& 5w0x0, 16w0x800 &&& 16w0x800, 8w0x0 &&& 8w0x0): parse_ingress_tstamp_3;
            (5w0x1 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x8 &&& 8w0xff): parse_int_tail;
            (5w0x2 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xc &&& 8w0xff): parse_int_tail;
            (5w0x3 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x10 &&& 8w0xff): parse_int_tail;
            (5w0x4 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x14 &&& 8w0xff): parse_int_tail;
            (5w0x5 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x18 &&& 8w0xff): parse_int_tail;
            (5w0x6 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x1c &&& 8w0xff): parse_int_tail;
            (5w0x7 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x20 &&& 8w0xff): parse_int_tail;
            (5w0x8 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x24 &&& 8w0xff): parse_int_tail;
            (5w0x0 &&& 5w0x0, 16w0x8000 &&& 16w0x8000, 8w0x0 &&& 8w0x0): parse_switch_id_5;
            (5w0x0 &&& 5w0x0, 16w0x4000 &&& 16w0x4000, 8w0x0 &&& 8w0x0): parse_port_ids_5;
            default: accept;
        }
    }
    @name(".parse_hop_latency_4") state parse_hop_latency_4 {
        packet.extract(hdr.int_hop_latency_4);
        meta.md_netcope.hop4_vld = 1w1;
        transition select(meta.md_netcope.INTinscnt, meta.md_netcope.INTinsmap, meta.md_netcope.INTlen) {
            (5w0x0 &&& 5w0x0, 16w0x1000 &&& 16w0x1000, 8w0x0 &&& 8w0x0): parse_q_occupancy_4;
            (5w0x0 &&& 5w0x0, 16w0x800 &&& 16w0x800, 8w0x0 &&& 8w0x0): parse_ingress_tstamp_4;
            (5w0x1 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x9 &&& 8w0xff): parse_int_tail;
            (5w0x2 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xe &&& 8w0xff): parse_int_tail;
            (5w0x3 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x13 &&& 8w0xff): parse_int_tail;
            (5w0x4 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x18 &&& 8w0xff): parse_int_tail;
            (5w0x5 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x1d &&& 8w0xff): parse_int_tail;
            (5w0x6 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x22 &&& 8w0xff): parse_int_tail;
            (5w0x7 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x27 &&& 8w0xff): parse_int_tail;
            (5w0x8 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x2c &&& 8w0xff): parse_int_tail;
            (5w0x0 &&& 5w0x0, 16w0x8000 &&& 16w0x8000, 8w0x0 &&& 8w0x0): parse_switch_id_5;
            (5w0x0 &&& 5w0x0, 16w0x4000 &&& 16w0x4000, 8w0x0 &&& 8w0x0): parse_port_ids_5;
            default: accept;
        }
    }
    @name(".parse_hop_latency_5") state parse_hop_latency_5 {
        packet.extract(hdr.int_hop_latency_5);
        meta.md_netcope.hop5_vld = 1w1;
        transition select(meta.md_netcope.INTinscnt, meta.md_netcope.INTinsmap, meta.md_netcope.INTlen) {
            (5w0x0 &&& 5w0x0, 16w0x1000 &&& 16w0x1000, 8w0x0 &&& 8w0x0): parse_q_occupancy_5;
            (5w0x0 &&& 5w0x0, 16w0x800 &&& 16w0x800, 8w0x0 &&& 8w0x0): parse_ingress_tstamp_5;
            (5w0x1 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x9 &&& 8w0xff): parse_int_tail;
            (5w0x2 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xe &&& 8w0xff): parse_int_tail;
            (5w0x3 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x13 &&& 8w0xff): parse_int_tail;
            (5w0x4 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x18 &&& 8w0xff): parse_int_tail;
            (5w0x5 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x1d &&& 8w0xff): parse_int_tail;
            (5w0x6 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x22 &&& 8w0xff): parse_int_tail;
            (5w0x7 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x27 &&& 8w0xff): parse_int_tail;
            (5w0x8 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x2c &&& 8w0xff): parse_int_tail;
            default: accept;
        }
    }
    @name(".parse_ingress_tstamp_0") state parse_ingress_tstamp_0 {
        packet.extract(hdr.int_ingress_tstamp_0);
        meta.md_netcope.hop0_vld = 1w1;
        transition select(meta.md_netcope.INTinscnt, meta.md_netcope.INTinsmap, meta.md_netcope.INTlen) {
            (5w0x1 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x5 &&& 8w0xff): parse_int_tail;
            (5w0x2 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x6 &&& 8w0xff): parse_int_tail;
            (5w0x3 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x7 &&& 8w0xff): parse_int_tail;
            (5w0x4 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x8 &&& 8w0xff): parse_int_tail;
            (5w0x5 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x9 &&& 8w0xff): parse_int_tail;
            (5w0x6 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xa &&& 8w0xff): parse_int_tail;
            (5w0x7 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xb &&& 8w0xff): parse_int_tail;
            (5w0x8 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xc &&& 8w0xff): parse_int_tail;
            (5w0x0 &&& 5w0x0, 16w0x8000 &&& 16w0x8000, 8w0x0 &&& 8w0x0): parse_switch_id_1;
            (5w0x0 &&& 5w0x0, 16w0x4000 &&& 16w0x4000, 8w0x0 &&& 8w0x0): parse_port_ids_1;
            (5w0x0 &&& 5w0x0, 16w0x1000 &&& 16w0x1000, 8w0x0 &&& 8w0x0): parse_q_occupancy_1;
            (5w0x0 &&& 5w0x0, 16w0x800 &&& 16w0x800, 8w0x0 &&& 8w0x0): parse_ingress_tstamp_1;
            default: accept;
        }
    }
    @name(".parse_ingress_tstamp_1") state parse_ingress_tstamp_1 {
        packet.extract(hdr.int_ingress_tstamp_1);
        meta.md_netcope.hop1_vld = 1w1;
        transition select(meta.md_netcope.INTinscnt, meta.md_netcope.INTinsmap, meta.md_netcope.INTlen) {
            (5w0x1 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x6 &&& 8w0xff): parse_int_tail;
            (5w0x2 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x8 &&& 8w0xff): parse_int_tail;
            (5w0x3 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xa &&& 8w0xff): parse_int_tail;
            (5w0x4 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xc &&& 8w0xff): parse_int_tail;
            (5w0x5 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xe &&& 8w0xff): parse_int_tail;
            (5w0x6 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x10 &&& 8w0xff): parse_int_tail;
            (5w0x7 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x12 &&& 8w0xff): parse_int_tail;
            (5w0x8 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x14 &&& 8w0xff): parse_int_tail;
            (5w0x0 &&& 5w0x0, 16w0x8000 &&& 16w0x8000, 8w0x0 &&& 8w0x0): parse_switch_id_2;
            (5w0x0 &&& 5w0x0, 16w0x4000 &&& 16w0x4000, 8w0x0 &&& 8w0x0): parse_port_ids_2;
            (5w0x0 &&& 5w0x0, 16w0x1000 &&& 16w0x1000, 8w0x0 &&& 8w0x0): parse_q_occupancy_2;
            (5w0x0 &&& 5w0x0, 16w0x800 &&& 16w0x800, 8w0x0 &&& 8w0x0): parse_ingress_tstamp_2;
            default: accept;
        }
    }
    @name(".parse_ingress_tstamp_2") state parse_ingress_tstamp_2 {
        packet.extract(hdr.int_ingress_tstamp_2);
        meta.md_netcope.hop2_vld = 1w1;
        transition select(meta.md_netcope.INTinscnt, meta.md_netcope.INTinsmap, meta.md_netcope.INTlen) {
            (5w0x1 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x7 &&& 8w0xff): parse_int_tail;
            (5w0x2 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xa &&& 8w0xff): parse_int_tail;
            (5w0x3 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xd &&& 8w0xff): parse_int_tail;
            (5w0x4 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x10 &&& 8w0xff): parse_int_tail;
            (5w0x5 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x13 &&& 8w0xff): parse_int_tail;
            (5w0x6 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x16 &&& 8w0xff): parse_int_tail;
            (5w0x7 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x19 &&& 8w0xff): parse_int_tail;
            (5w0x8 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x1c &&& 8w0xff): parse_int_tail;
            (5w0x0 &&& 5w0x0, 16w0x8000 &&& 16w0x8000, 8w0x0 &&& 8w0x0): parse_switch_id_3;
            (5w0x0 &&& 5w0x0, 16w0x4000 &&& 16w0x4000, 8w0x0 &&& 8w0x0): parse_port_ids_3;
            (5w0x0 &&& 5w0x0, 16w0x1000 &&& 16w0x1000, 8w0x0 &&& 8w0x0): parse_q_occupancy_3;
            (5w0x0 &&& 5w0x0, 16w0x800 &&& 16w0x800, 8w0x0 &&& 8w0x0): parse_ingress_tstamp_3;
            default: accept;
        }
    }
    @name(".parse_ingress_tstamp_3") state parse_ingress_tstamp_3 {
        packet.extract(hdr.int_ingress_tstamp_3);
        meta.md_netcope.hop3_vld = 1w1;
        transition select(meta.md_netcope.INTinscnt, meta.md_netcope.INTinsmap, meta.md_netcope.INTlen) {
            (5w0x1 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x8 &&& 8w0xff): parse_int_tail;
            (5w0x2 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xc &&& 8w0xff): parse_int_tail;
            (5w0x3 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x10 &&& 8w0xff): parse_int_tail;
            (5w0x4 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x14 &&& 8w0xff): parse_int_tail;
            (5w0x5 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x18 &&& 8w0xff): parse_int_tail;
            (5w0x6 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x1c &&& 8w0xff): parse_int_tail;
            (5w0x7 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x20 &&& 8w0xff): parse_int_tail;
            (5w0x8 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x24 &&& 8w0xff): parse_int_tail;
            (5w0x0 &&& 5w0x0, 16w0x8000 &&& 16w0x8000, 8w0x0 &&& 8w0x0): parse_switch_id_5;
            (5w0x0 &&& 5w0x0, 16w0x4000 &&& 16w0x4000, 8w0x0 &&& 8w0x0): parse_port_ids_5;
            (5w0x0 &&& 5w0x0, 16w0x1000 &&& 16w0x1000, 8w0x0 &&& 8w0x0): parse_q_occupancy_5;
            (5w0x0 &&& 5w0x0, 16w0x800 &&& 16w0x800, 8w0x0 &&& 8w0x0): parse_ingress_tstamp_5;
            default: accept;
        }
    }
    @name(".parse_ingress_tstamp_4") state parse_ingress_tstamp_4 {
        packet.extract(hdr.int_ingress_tstamp_4);
        meta.md_netcope.hop4_vld = 1w1;
        transition select(meta.md_netcope.INTinscnt, meta.md_netcope.INTinsmap, meta.md_netcope.INTlen) {
            (5w0x1 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x9 &&& 8w0xff): parse_int_tail;
            (5w0x2 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xe &&& 8w0xff): parse_int_tail;
            (5w0x3 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x13 &&& 8w0xff): parse_int_tail;
            (5w0x4 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x18 &&& 8w0xff): parse_int_tail;
            (5w0x5 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x1d &&& 8w0xff): parse_int_tail;
            (5w0x6 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x22 &&& 8w0xff): parse_int_tail;
            (5w0x7 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x27 &&& 8w0xff): parse_int_tail;
            (5w0x8 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x2c &&& 8w0xff): parse_int_tail;
            (5w0x0 &&& 5w0x0, 16w0x8000 &&& 16w0x8000, 8w0x0 &&& 8w0x0): parse_switch_id_5;
            (5w0x0 &&& 5w0x0, 16w0x4000 &&& 16w0x4000, 8w0x0 &&& 8w0x0): parse_port_ids_5;
            (5w0x0 &&& 5w0x0, 16w0x1000 &&& 16w0x1000, 8w0x0 &&& 8w0x0): parse_q_occupancy_5;
            (5w0x0 &&& 5w0x0, 16w0x800 &&& 16w0x800, 8w0x0 &&& 8w0x0): parse_ingress_tstamp_5;
            default: accept;
        }
    }
    @name(".parse_ingress_tstamp_5") state parse_ingress_tstamp_5 {
        packet.extract(hdr.int_ingress_tstamp_5);
        meta.md_netcope.hop5_vld = 1w1;
        transition select(meta.md_netcope.INTinscnt, meta.md_netcope.INTinsmap, meta.md_netcope.INTlen) {
            (5w0x0 &&& 5w0x0, 16w0x400 &&& 16w0x400, 8w0x0 &&& 8w0x0): parse_egress_tstamp_5;
            (5w0x1 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x9 &&& 8w0xff): parse_int_tail;
            (5w0x2 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xe &&& 8w0xff): parse_int_tail;
            (5w0x3 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x13 &&& 8w0xff): parse_int_tail;
            (5w0x4 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x18 &&& 8w0xff): parse_int_tail;
            (5w0x5 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x1d &&& 8w0xff): parse_int_tail;
            (5w0x6 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x22 &&& 8w0xff): parse_int_tail;
            (5w0x7 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x27 &&& 8w0xff): parse_int_tail;
            (5w0x8 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x2c &&& 8w0xff): parse_int_tail;
            default: accept;
        }
    }
    @name(".parse_int_header") state parse_int_header {
        packet.extract(hdr.int_header);
        meta.md_netcope.INTinsmap = hdr.int_header.instruction_map;
        meta.md_netcope.INTinscnt = hdr.int_header.ins_cnt;
        transition select(hdr.int_header.ins_cnt, hdr.int_header.instruction_map, meta.md_netcope.INTlen) {
            (5w0x0 &&& 5w0x0, 16w0x0 &&& 16w0x0, 8w0x4 &&& 8w0xff): parse_int_tail; 
            (5w0x0 &&& 5w0x0, 16w0x8000 &&& 16w0x8000, 8w0x0 &&& 8w0x0): parse_switch_id_0; 
            (5w0x0 &&& 5w0x0, 16w0x4000 &&& 16w0x4000, 8w0x0 &&& 8w0x0): parse_port_ids_0;
            (5w0x0 &&& 5w0x0, 16w0x1000 &&& 16w0x1000, 8w0x0 &&& 8w0x0): parse_q_occupancy_0;
            (5w0x0 &&& 5w0x0, 16w0x800 &&& 16w0x800, 8w0x0 &&& 8w0x0): parse_ingress_tstamp_0;
            default: accept;
        }
    }
    @name(".parse_int_shim") state parse_int_shim {
        packet.extract(hdr.int_shim);
        meta.md_netcope.INTlen = hdr.int_shim.len;
        transition parse_int_header;
    }
    @name(".parse_int_tail") state parse_int_tail {
        packet.extract(hdr.int_tail);
        meta.md_netcope.valid_int = 1w1;
        transition accept;
    }
    @name(".parse_ipv4") state parse_ipv4 {
        packet.extract(hdr.ipv4);
        meta.md_netcope.IPsrc = hdr.ipv4.srcAddr;
        meta.md_netcope.IPdst = hdr.ipv4.dstAddr;
        meta.md_netcope.IPver = 8w4;
        meta.internal_metadata.dscp = hdr.ipv4.dscp;
        transition select(hdr.ipv4.protocol) {
            8w0x11: parse_udp;
            8w0x6: parse_tcp;
            default: accept;
        }
    }
    @name(".parse_port_ids_0") state parse_port_ids_0 {
        packet.extract(hdr.int_port_ids_0);
        meta.md_netcope.hop0_vld = 1w1;
        transition select(meta.md_netcope.INTinscnt, meta.md_netcope.INTinsmap, meta.md_netcope.INTlen) {
            (5w0x0 &&& 5w0x0, 16w0x1000 &&& 16w0x1000, 8w0x0 &&& 8w0x0): parse_q_occupancy_0;
            (5w0x0 &&& 5w0x0, 16w0x800 &&& 16w0x800, 8w0x0 &&& 8w0x0): parse_ingress_tstamp_0;
            (5w0x1 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x5 &&& 8w0xff): parse_int_tail;
            (5w0x2 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x6 &&& 8w0xff): parse_int_tail;
            (5w0x3 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x7 &&& 8w0xff): parse_int_tail;
            (5w0x4 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x8 &&& 8w0xff): parse_int_tail;
            (5w0x5 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x9 &&& 8w0xff): parse_int_tail;
            (5w0x6 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xa &&& 8w0xff): parse_int_tail;
            (5w0x7 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xb &&& 8w0xff): parse_int_tail;
            (5w0x8 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xc &&& 8w0xff): parse_int_tail;
            (5w0x0 &&& 5w0x0, 16w0x8000 &&& 16w0x8000, 8w0x0 &&& 8w0x0): parse_switch_id_1;
            (5w0x0 &&& 5w0x0, 16w0x4000 &&& 16w0x4000, 8w0x0 &&& 8w0x0): parse_port_ids_1;
            default: accept;
        }
    }
    @name(".parse_port_ids_1") state parse_port_ids_1 {
        packet.extract(hdr.int_port_ids_1);
        meta.md_netcope.hop1_vld = 1w1;
        transition select(meta.md_netcope.INTinscnt, meta.md_netcope.INTinsmap, meta.md_netcope.INTlen) {
            (5w0x0 &&& 5w0x0, 16w0x1000 &&& 16w0x1000, 8w0x0 &&& 8w0x0): parse_q_occupancy_1;
            (5w0x0 &&& 5w0x0, 16w0x800 &&& 16w0x800, 8w0x0 &&& 8w0x0): parse_ingress_tstamp_1;
            (5w0x1 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x6 &&& 8w0xff): parse_int_tail;
            (5w0x2 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x8 &&& 8w0xff): parse_int_tail;
            (5w0x3 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xa &&& 8w0xff): parse_int_tail;
            (5w0x4 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xc &&& 8w0xff): parse_int_tail;
            (5w0x5 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xe &&& 8w0xff): parse_int_tail;
            (5w0x6 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x10 &&& 8w0xff): parse_int_tail;
            (5w0x7 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x12 &&& 8w0xff): parse_int_tail;
            (5w0x8 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x14 &&& 8w0xff): parse_int_tail;
            (5w0x0 &&& 5w0x0, 16w0x8000 &&& 16w0x8000, 8w0x0 &&& 8w0x0): parse_switch_id_2;
            (5w0x0 &&& 5w0x0, 16w0x4000 &&& 16w0x4000, 8w0x0 &&& 8w0x0): parse_port_ids_2;
            default: accept;
        }
    }
    @name(".parse_port_ids_2") state parse_port_ids_2 {
        packet.extract(hdr.int_port_ids_2);
        meta.md_netcope.hop2_vld = 1w1;
        transition select(meta.md_netcope.INTinscnt, meta.md_netcope.INTinsmap, meta.md_netcope.INTlen) {
            (5w0x0 &&& 5w0x0, 16w0x1000 &&& 16w0x1000, 8w0x0 &&& 8w0x0): parse_q_occupancy_2;
            (5w0x0 &&& 5w0x0, 16w0x800 &&& 16w0x800, 8w0x0 &&& 8w0x0): parse_ingress_tstamp_2;
            (5w0x1 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x7 &&& 8w0xff): parse_int_tail;
            (5w0x2 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xa &&& 8w0xff): parse_int_tail;
            (5w0x3 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xd &&& 8w0xff): parse_int_tail;
            (5w0x4 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x10 &&& 8w0xff): parse_int_tail;
            (5w0x5 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x13 &&& 8w0xff): parse_int_tail;
            (5w0x6 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x16 &&& 8w0xff): parse_int_tail;
            (5w0x7 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x19 &&& 8w0xff): parse_int_tail;
            (5w0x8 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x1c &&& 8w0xff): parse_int_tail;
            (5w0x0 &&& 5w0x0, 16w0x8000 &&& 16w0x8000, 8w0x0 &&& 8w0x0): parse_switch_id_3;
            (5w0x0 &&& 5w0x0, 16w0x4000 &&& 16w0x4000, 8w0x0 &&& 8w0x0): parse_port_ids_3;
            default: accept;
        }
    }
    @name(".parse_port_ids_3") state parse_port_ids_3 {
        packet.extract(hdr.int_port_ids_3);
        meta.md_netcope.hop3_vld = 1w1;
        transition select(meta.md_netcope.INTinscnt, meta.md_netcope.INTinsmap, meta.md_netcope.INTlen) {
            (5w0x0 &&& 5w0x0, 16w0x1000 &&& 16w0x1000, 8w0x0 &&& 8w0x0): parse_q_occupancy_3;
            (5w0x0 &&& 5w0x0, 16w0x800 &&& 16w0x800, 8w0x0 &&& 8w0x0): parse_ingress_tstamp_3;
            (5w0x1 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x8 &&& 8w0xff): parse_int_tail;
            (5w0x2 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xc &&& 8w0xff): parse_int_tail;
            (5w0x3 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x10 &&& 8w0xff): parse_int_tail;
            (5w0x4 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x14 &&& 8w0xff): parse_int_tail;
            (5w0x5 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x18 &&& 8w0xff): parse_int_tail;
            (5w0x6 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x1c &&& 8w0xff): parse_int_tail;
            (5w0x7 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x20 &&& 8w0xff): parse_int_tail;
            (5w0x8 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x24 &&& 8w0xff): parse_int_tail;
            (5w0x0 &&& 5w0x0, 16w0x8000 &&& 16w0x8000, 8w0x0 &&& 8w0x0): parse_switch_id_5;
            (5w0x0 &&& 5w0x0, 16w0x4000 &&& 16w0x4000, 8w0x0 &&& 8w0x0): parse_port_ids_5;
            default: accept;
        }
    }
    @name(".parse_port_ids_4") state parse_port_ids_4 {
        packet.extract(hdr.int_port_ids_4);
        meta.md_netcope.hop4_vld = 1w1;
        transition select(meta.md_netcope.INTinscnt, meta.md_netcope.INTinsmap, meta.md_netcope.INTlen) {
            (5w0x0 &&& 5w0x0, 16w0x1000 &&& 16w0x1000, 8w0x0 &&& 8w0x0): parse_q_occupancy_4;
            (5w0x0 &&& 5w0x0, 16w0x800 &&& 16w0x800, 8w0x0 &&& 8w0x0): parse_ingress_tstamp_4;
            (5w0x1 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x9 &&& 8w0xff): parse_int_tail;
            (5w0x2 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xe &&& 8w0xff): parse_int_tail;
            (5w0x3 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x13 &&& 8w0xff): parse_int_tail;
            (5w0x4 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x18 &&& 8w0xff): parse_int_tail;
            (5w0x5 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x1d &&& 8w0xff): parse_int_tail;
            (5w0x6 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x22 &&& 8w0xff): parse_int_tail;
            (5w0x7 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x27 &&& 8w0xff): parse_int_tail;
            (5w0x8 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x2c &&& 8w0xff): parse_int_tail;
            (5w0x0 &&& 5w0x0, 16w0x8000 &&& 16w0x8000, 8w0x0 &&& 8w0x0): parse_switch_id_5;
            (5w0x0 &&& 5w0x0, 16w0x4000 &&& 16w0x4000, 8w0x0 &&& 8w0x0): parse_port_ids_5;
            default: accept;
        }
    }
    @name(".parse_port_ids_5") state parse_port_ids_5 {
        packet.extract(hdr.int_port_ids_5);
        meta.md_netcope.hop5_vld = 1w1;
        transition select(meta.md_netcope.INTinscnt, meta.md_netcope.INTinsmap, meta.md_netcope.INTlen) {
            (5w0x0 &&& 5w0x0, 16w0x1000 &&& 16w0x1000, 8w0x0 &&& 8w0x0): parse_q_occupancy_5;
            (5w0x0 &&& 5w0x0, 16w0x800 &&& 16w0x800, 8w0x0 &&& 8w0x0): parse_ingress_tstamp_5;
            (5w0x1 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x9 &&& 8w0xff): parse_int_tail;
            (5w0x2 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xe &&& 8w0xff): parse_int_tail;
            (5w0x3 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x13 &&& 8w0xff): parse_int_tail;
            (5w0x4 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x18 &&& 8w0xff): parse_int_tail;
            (5w0x5 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x1d &&& 8w0xff): parse_int_tail;
            (5w0x6 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x22 &&& 8w0xff): parse_int_tail;
            (5w0x7 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x27 &&& 8w0xff): parse_int_tail;
            (5w0x8 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x2c &&& 8w0xff): parse_int_tail;
            default: accept;
        }
    }
    @name(".parse_q_congestion_0") state parse_q_congestion_0 {
        packet.extract(hdr.int_q_congestion_0);
        meta.md_netcope.hop0_vld = 1w1;
        transition select(meta.md_netcope.INTinscnt, meta.md_netcope.INTinsmap, meta.md_netcope.INTlen) {
            (5w0x1 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x5 &&& 8w0xff): parse_int_tail;
            (5w0x2 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x6 &&& 8w0xff): parse_int_tail;
            (5w0x3 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x7 &&& 8w0xff): parse_int_tail;
            (5w0x4 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x8 &&& 8w0xff): parse_int_tail;
            (5w0x5 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x9 &&& 8w0xff): parse_int_tail;
            (5w0x6 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xa &&& 8w0xff): parse_int_tail;
            (5w0x7 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xb &&& 8w0xff): parse_int_tail;
            (5w0x8 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xc &&& 8w0xff): parse_int_tail;
            (5w0x0 &&& 5w0x0, 16w0x8000 &&& 16w0x8000, 8w0x0 &&& 8w0x0): parse_switch_id_1;
            (5w0x0 &&& 5w0x0, 16w0x4000 &&& 16w0x4000, 8w0x0 &&& 8w0x0): parse_port_ids_1;
            (5w0x0 &&& 5w0x0, 16w0x1000 &&& 16w0x1000, 8w0x0 &&& 8w0x0): parse_q_occupancy_1;
            (5w0x0 &&& 5w0x0, 16w0x800 &&& 16w0x800, 8w0x0 &&& 8w0x0): parse_ingress_tstamp_1;
            default: accept;
        }
    }
    @name(".parse_q_congestion_1") state parse_q_congestion_1 {
        packet.extract(hdr.int_q_congestion_1);
        meta.md_netcope.hop1_vld = 1w1;
        transition select(meta.md_netcope.INTinscnt, meta.md_netcope.INTinsmap, meta.md_netcope.INTlen) {
            (5w0x1 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x6 &&& 8w0xff): parse_int_tail;
            (5w0x2 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x8 &&& 8w0xff): parse_int_tail;
            (5w0x3 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xa &&& 8w0xff): parse_int_tail;
            (5w0x4 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xc &&& 8w0xff): parse_int_tail;
            (5w0x5 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xe &&& 8w0xff): parse_int_tail;
            (5w0x6 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x10 &&& 8w0xff): parse_int_tail;
            (5w0x7 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x12 &&& 8w0xff): parse_int_tail;
            (5w0x8 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x14 &&& 8w0xff): parse_int_tail;
            (5w0x0 &&& 5w0x0, 16w0x8000 &&& 16w0x8000, 8w0x0 &&& 8w0x0): parse_switch_id_2;
            (5w0x0 &&& 5w0x0, 16w0x4000 &&& 16w0x4000, 8w0x0 &&& 8w0x0): parse_port_ids_2;
            (5w0x0 &&& 5w0x0, 16w0x1000 &&& 16w0x1000, 8w0x0 &&& 8w0x0): parse_q_occupancy_2;
            (5w0x0 &&& 5w0x0, 16w0x800 &&& 16w0x800, 8w0x0 &&& 8w0x0): parse_ingress_tstamp_2;
            default: accept;
        }
    }
    @name(".parse_q_congestion_2") state parse_q_congestion_2 {
        packet.extract(hdr.int_q_congestion_2);
        meta.md_netcope.hop2_vld = 1w1;
        transition select(meta.md_netcope.INTinscnt, meta.md_netcope.INTinsmap, meta.md_netcope.INTlen) {
            (5w0x1 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x7 &&& 8w0xff): parse_int_tail;
            (5w0x2 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xa &&& 8w0xff): parse_int_tail;
            (5w0x3 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xd &&& 8w0xff): parse_int_tail;
            (5w0x4 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x10 &&& 8w0xff): parse_int_tail;
            (5w0x5 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x13 &&& 8w0xff): parse_int_tail;
            (5w0x6 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x16 &&& 8w0xff): parse_int_tail;
            (5w0x7 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x19 &&& 8w0xff): parse_int_tail;
            (5w0x8 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x1c &&& 8w0xff): parse_int_tail;
            (5w0x0 &&& 5w0x0, 16w0x8000 &&& 16w0x8000, 8w0x0 &&& 8w0x0): parse_switch_id_3;
            (5w0x0 &&& 5w0x0, 16w0x4000 &&& 16w0x4000, 8w0x0 &&& 8w0x0): parse_port_ids_3;
            (5w0x0 &&& 5w0x0, 16w0x1000 &&& 16w0x1000, 8w0x0 &&& 8w0x0): parse_q_occupancy_3;
            (5w0x0 &&& 5w0x0, 16w0x800 &&& 16w0x800, 8w0x0 &&& 8w0x0): parse_ingress_tstamp_3;
            default: accept;
        }
    }
    @name(".parse_q_congestion_3") state parse_q_congestion_3 {
        packet.extract(hdr.int_q_congestion_3);
        meta.md_netcope.hop3_vld = 1w1;
        transition select(meta.md_netcope.INTinscnt, meta.md_netcope.INTinsmap, meta.md_netcope.INTlen) {
            (5w0x1 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x8 &&& 8w0xff): parse_int_tail;
            (5w0x2 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xc &&& 8w0xff): parse_int_tail;
            (5w0x3 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x10 &&& 8w0xff): parse_int_tail;
            (5w0x4 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x14 &&& 8w0xff): parse_int_tail;
            (5w0x5 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x18 &&& 8w0xff): parse_int_tail;
            (5w0x6 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x1c &&& 8w0xff): parse_int_tail;
            (5w0x7 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x20 &&& 8w0xff): parse_int_tail;
            (5w0x8 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x24 &&& 8w0xff): parse_int_tail;
            (5w0x0 &&& 5w0x0, 16w0x8000 &&& 16w0x8000, 8w0x0 &&& 8w0x0): parse_switch_id_5;
            (5w0x0 &&& 5w0x0, 16w0x4000 &&& 16w0x4000, 8w0x0 &&& 8w0x0): parse_port_ids_5;
            (5w0x0 &&& 5w0x0, 16w0x1000 &&& 16w0x1000, 8w0x0 &&& 8w0x0): parse_q_occupancy_5;
            (5w0x0 &&& 5w0x0, 16w0x800 &&& 16w0x800, 8w0x0 &&& 8w0x0): parse_ingress_tstamp_5;
            default: accept;
        }
    }
    @name(".parse_q_congestion_4") state parse_q_congestion_4 {
        packet.extract(hdr.int_q_congestion_4);
        meta.md_netcope.hop4_vld = 1w1;
        transition select(meta.md_netcope.INTinscnt, meta.md_netcope.INTinsmap, meta.md_netcope.INTlen) {
            (5w0x1 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x9 &&& 8w0xff): parse_int_tail;
            (5w0x2 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xe &&& 8w0xff): parse_int_tail;
            (5w0x3 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x13 &&& 8w0xff): parse_int_tail;
            (5w0x4 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x18 &&& 8w0xff): parse_int_tail;
            (5w0x5 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x1d &&& 8w0xff): parse_int_tail;
            (5w0x6 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x22 &&& 8w0xff): parse_int_tail;
            (5w0x7 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x27 &&& 8w0xff): parse_int_tail;
            (5w0x8 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x2c &&& 8w0xff): parse_int_tail;
            (5w0x0 &&& 5w0x0, 16w0x8000 &&& 16w0x8000, 8w0x0 &&& 8w0x0): parse_switch_id_5;
            (5w0x0 &&& 5w0x0, 16w0x4000 &&& 16w0x4000, 8w0x0 &&& 8w0x0): parse_port_ids_5;
            (5w0x0 &&& 5w0x0, 16w0x1000 &&& 16w0x1000, 8w0x0 &&& 8w0x0): parse_q_occupancy_5;
            (5w0x0 &&& 5w0x0, 16w0x800 &&& 16w0x800, 8w0x0 &&& 8w0x0): parse_ingress_tstamp_5;
            default: accept;
        }
    }
    @name(".parse_q_congestion_5") state parse_q_congestion_5 {
        packet.extract(hdr.int_q_congestion_5);
        meta.md_netcope.hop5_vld = 1w1;
        transition select(meta.md_netcope.INTinscnt, meta.md_netcope.INTinsmap, meta.md_netcope.INTlen) {
            (5w0x1 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x9 &&& 8w0xff): parse_int_tail;
            (5w0x2 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xe &&& 8w0xff): parse_int_tail;
            (5w0x3 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x13 &&& 8w0xff): parse_int_tail;
            (5w0x4 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x18 &&& 8w0xff): parse_int_tail;
            (5w0x5 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x1d &&& 8w0xff): parse_int_tail;
            (5w0x6 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x22 &&& 8w0xff): parse_int_tail;
            (5w0x7 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x27 &&& 8w0xff): parse_int_tail;
            (5w0x8 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x2c &&& 8w0xff): parse_int_tail;
            default: accept;
        }
    }
    @name(".parse_q_occupancy_0") state parse_q_occupancy_0 {
        packet.extract(hdr.int_q_occupancy_0);
        meta.md_netcope.hop0_vld = 1w1;
        transition select(meta.md_netcope.INTinscnt, meta.md_netcope.INTinsmap, meta.md_netcope.INTlen) {
            (5w0x0 &&& 5w0x0, 16w0x800 &&& 16w0x800, 8w0x0 &&& 8w0x0): parse_ingress_tstamp_0;
            (5w0x1 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x5 &&& 8w0xff): parse_int_tail;
            (5w0x2 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x6 &&& 8w0xff): parse_int_tail;
            (5w0x3 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x7 &&& 8w0xff): parse_int_tail;
            (5w0x4 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x8 &&& 8w0xff): parse_int_tail;
            (5w0x5 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x9 &&& 8w0xff): parse_int_tail;
            (5w0x6 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xa &&& 8w0xff): parse_int_tail;
            (5w0x7 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xb &&& 8w0xff): parse_int_tail;
            (5w0x8 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xc &&& 8w0xff): parse_int_tail;
            (5w0x0 &&& 5w0x0, 16w0x8000 &&& 16w0x8000, 8w0x0 &&& 8w0x0): parse_switch_id_1;
            (5w0x0 &&& 5w0x0, 16w0x4000 &&& 16w0x4000, 8w0x0 &&& 8w0x0): parse_port_ids_1;
            (5w0x0 &&& 5w0x0, 16w0x1000 &&& 16w0x1000, 8w0x0 &&& 8w0x0): parse_q_occupancy_1;
            default: accept;
        }
    }
    @name(".parse_q_occupancy_1") state parse_q_occupancy_1 {
        packet.extract(hdr.int_q_occupancy_1);
        meta.md_netcope.hop1_vld = 1w1;
        transition select(meta.md_netcope.INTinscnt, meta.md_netcope.INTinsmap, meta.md_netcope.INTlen) {
            (5w0x0 &&& 5w0x0, 16w0x800 &&& 16w0x800, 8w0x0 &&& 8w0x0): parse_ingress_tstamp_1;
            (5w0x1 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x6 &&& 8w0xff): parse_int_tail;
            (5w0x2 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x8 &&& 8w0xff): parse_int_tail;
            (5w0x3 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xa &&& 8w0xff): parse_int_tail;
            (5w0x4 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xc &&& 8w0xff): parse_int_tail;
            (5w0x5 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xe &&& 8w0xff): parse_int_tail;
            (5w0x6 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x10 &&& 8w0xff): parse_int_tail;
            (5w0x7 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x12 &&& 8w0xff): parse_int_tail;
            (5w0x8 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x14 &&& 8w0xff): parse_int_tail;
            (5w0x0 &&& 5w0x0, 16w0x8000 &&& 16w0x8000, 8w0x0 &&& 8w0x0): parse_switch_id_2;
            (5w0x0 &&& 5w0x0, 16w0x4000 &&& 16w0x4000, 8w0x0 &&& 8w0x0): parse_port_ids_2;
            (5w0x0 &&& 5w0x0, 16w0x1000 &&& 16w0x1000, 8w0x0 &&& 8w0x0): parse_q_occupancy_2;
            default: accept;
        }
    }
    @name(".parse_q_occupancy_2") state parse_q_occupancy_2 {
        packet.extract(hdr.int_q_occupancy_2);
        meta.md_netcope.hop2_vld = 1w1;
        transition select(meta.md_netcope.INTinscnt, meta.md_netcope.INTinsmap, meta.md_netcope.INTlen) {
            (5w0x0 &&& 5w0x0, 16w0x800 &&& 16w0x800, 8w0x0 &&& 8w0x0): parse_ingress_tstamp_2;
            (5w0x1 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x7 &&& 8w0xff): parse_int_tail;
            (5w0x2 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xa &&& 8w0xff): parse_int_tail;
            (5w0x3 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xd &&& 8w0xff): parse_int_tail;
            (5w0x4 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x10 &&& 8w0xff): parse_int_tail;
            (5w0x5 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x13 &&& 8w0xff): parse_int_tail;
            (5w0x6 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x16 &&& 8w0xff): parse_int_tail;
            (5w0x7 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x19 &&& 8w0xff): parse_int_tail;
            (5w0x8 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x1c &&& 8w0xff): parse_int_tail;
            (5w0x0 &&& 5w0x0, 16w0x8000 &&& 16w0x8000, 8w0x0 &&& 8w0x0): parse_switch_id_3;
            (5w0x0 &&& 5w0x0, 16w0x4000 &&& 16w0x4000, 8w0x0 &&& 8w0x0): parse_port_ids_3;
            (5w0x0 &&& 5w0x0, 16w0x1000 &&& 16w0x1000, 8w0x0 &&& 8w0x0): parse_q_occupancy_3;
            default: accept;
        }
    }
    @name(".parse_q_occupancy_3") state parse_q_occupancy_3 {
        packet.extract(hdr.int_q_occupancy_3);
        meta.md_netcope.hop3_vld = 1w1;
        transition select(meta.md_netcope.INTinscnt, meta.md_netcope.INTinsmap, meta.md_netcope.INTlen) {
            (5w0x0 &&& 5w0x0, 16w0x800 &&& 16w0x800, 8w0x0 &&& 8w0x0): parse_ingress_tstamp_3;
            (5w0x1 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x8 &&& 8w0xff): parse_int_tail;
            (5w0x2 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xc &&& 8w0xff): parse_int_tail;
            (5w0x3 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x10 &&& 8w0xff): parse_int_tail;
            (5w0x4 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x14 &&& 8w0xff): parse_int_tail;
            (5w0x5 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x18 &&& 8w0xff): parse_int_tail;
            (5w0x6 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x1c &&& 8w0xff): parse_int_tail;
            (5w0x7 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x20 &&& 8w0xff): parse_int_tail;
            (5w0x8 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x24 &&& 8w0xff): parse_int_tail;
            (5w0x0 &&& 5w0x0, 16w0x8000 &&& 16w0x8000, 8w0x0 &&& 8w0x0): parse_switch_id_5;
            (5w0x0 &&& 5w0x0, 16w0x4000 &&& 16w0x4000, 8w0x0 &&& 8w0x0): parse_port_ids_5;
            (5w0x0 &&& 5w0x0, 16w0x1000 &&& 16w0x1000, 8w0x0 &&& 8w0x0): parse_q_occupancy_5;
            default: accept;
        }
    }
    @name(".parse_q_occupancy_4") state parse_q_occupancy_4 {
        packet.extract(hdr.int_q_occupancy_4);
        meta.md_netcope.hop4_vld = 1w1;
        transition select(meta.md_netcope.INTinscnt, meta.md_netcope.INTinsmap, meta.md_netcope.INTlen) {
            (5w0x0 &&& 5w0x0, 16w0x800 &&& 16w0x800, 8w0x0 &&& 8w0x0): parse_ingress_tstamp_4;
            (5w0x1 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x9 &&& 8w0xff): parse_int_tail;
            (5w0x2 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xe &&& 8w0xff): parse_int_tail;
            (5w0x3 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x13 &&& 8w0xff): parse_int_tail;
            (5w0x4 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x18 &&& 8w0xff): parse_int_tail;
            (5w0x5 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x1d &&& 8w0xff): parse_int_tail;
            (5w0x6 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x22 &&& 8w0xff): parse_int_tail;
            (5w0x7 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x27 &&& 8w0xff): parse_int_tail;
            (5w0x8 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x2c &&& 8w0xff): parse_int_tail;
            (5w0x0 &&& 5w0x0, 16w0x8000 &&& 16w0x8000, 8w0x0 &&& 8w0x0): parse_switch_id_5;
            (5w0x0 &&& 5w0x0, 16w0x4000 &&& 16w0x4000, 8w0x0 &&& 8w0x0): parse_port_ids_5;
            (5w0x0 &&& 5w0x0, 16w0x1000 &&& 16w0x1000, 8w0x0 &&& 8w0x0): parse_q_occupancy_5;
            default: accept;
        }
    }
    @name(".parse_q_occupancy_5") state parse_q_occupancy_5 {
        packet.extract(hdr.int_q_occupancy_5);
        meta.md_netcope.hop5_vld = 1w1;
        transition select(meta.md_netcope.INTinscnt, meta.md_netcope.INTinsmap, meta.md_netcope.INTlen) {
            (5w0x0 &&& 5w0x0, 16w0x800 &&& 16w0x800, 8w0x0 &&& 8w0x0): parse_ingress_tstamp_5;
            (5w0x0 &&& 5w0x0, 16w0x400 &&& 16w0x400, 8w0x0 &&& 8w0x0): parse_egress_tstamp_5;
            (5w0x1 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x9 &&& 8w0xff): parse_int_tail;
            (5w0x2 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xe &&& 8w0xff): parse_int_tail;
            (5w0x3 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x13 &&& 8w0xff): parse_int_tail;
            (5w0x4 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x18 &&& 8w0xff): parse_int_tail;
            (5w0x5 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x1d &&& 8w0xff): parse_int_tail;
            (5w0x6 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x22 &&& 8w0xff): parse_int_tail;
            (5w0x7 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x27 &&& 8w0xff): parse_int_tail;
            (5w0x8 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x2c &&& 8w0xff): parse_int_tail;
            default: accept;
        }
    }
    @name(".parse_switch_id_0") state parse_switch_id_0 {
        packet.extract(hdr.int_switch_id_0);
        meta.md_netcope.hop0_vld = 1w1;
        transition select(meta.md_netcope.INTinscnt, meta.md_netcope.INTinsmap, meta.md_netcope.INTlen) {
            (5w0x0 &&& 5w0x0, 16w0x4000 &&& 16w0x4000, 8w0x0 &&& 8w0x0): parse_port_ids_0;
            (5w0x0 &&& 5w0x0, 16w0x1000 &&& 16w0x1000, 8w0x0 &&& 8w0x0): parse_q_occupancy_0;
            (5w0x0 &&& 5w0x0, 16w0x800 &&& 16w0x800, 8w0x0 &&& 8w0x0): parse_ingress_tstamp_0;
            (5w0x1 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x5 &&& 8w0xff): parse_int_tail;
            (5w0x2 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x6 &&& 8w0xff): parse_int_tail;
            (5w0x3 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x7 &&& 8w0xff): parse_int_tail;
            (5w0x4 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x8 &&& 8w0xff): parse_int_tail;
            (5w0x5 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x9 &&& 8w0xff): parse_int_tail;
            (5w0x6 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xa &&& 8w0xff): parse_int_tail;
            (5w0x7 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xb &&& 8w0xff): parse_int_tail;
            (5w0x8 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xc &&& 8w0xff): parse_int_tail;
            (5w0x0 &&& 5w0x0, 16w0x8000 &&& 16w0x8000, 8w0x0 &&& 8w0x0): parse_switch_id_1;
            default: accept;
        }
    }
    @name(".parse_switch_id_1") state parse_switch_id_1 {
        packet.extract(hdr.int_switch_id_1);
        meta.md_netcope.hop1_vld = 1w1;
        transition select(meta.md_netcope.INTinscnt, meta.md_netcope.INTinsmap, meta.md_netcope.INTlen) {
            (5w0x0 &&& 5w0x0, 16w0x4000 &&& 16w0x4000, 8w0x0 &&& 8w0x0): parse_port_ids_1;
            (5w0x0 &&& 5w0x0, 16w0x1000 &&& 16w0x1000, 8w0x0 &&& 8w0x0): parse_q_occupancy_1;
            (5w0x0 &&& 5w0x0, 16w0x800 &&& 16w0x800, 8w0x0 &&& 8w0x0): parse_ingress_tstamp_1;
            (5w0x1 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x6 &&& 8w0xff): parse_int_tail;
            (5w0x2 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x8 &&& 8w0xff): parse_int_tail;
            (5w0x3 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xa &&& 8w0xff): parse_int_tail;
            (5w0x4 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xc &&& 8w0xff): parse_int_tail;
            (5w0x5 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xe &&& 8w0xff): parse_int_tail;
            (5w0x6 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x10 &&& 8w0xff): parse_int_tail;
            (5w0x7 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x12 &&& 8w0xff): parse_int_tail;
            (5w0x8 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x14 &&& 8w0xff): parse_int_tail;
            (5w0x0 &&& 5w0x0, 16w0x8000 &&& 16w0x8000, 8w0x0 &&& 8w0x0): parse_switch_id_2;
            default: accept;
        }
    }
    @name(".parse_switch_id_2") state parse_switch_id_2 {
        packet.extract(hdr.int_switch_id_2);
        meta.md_netcope.hop2_vld = 1w1;
        transition select(meta.md_netcope.INTinscnt, meta.md_netcope.INTinsmap, meta.md_netcope.INTlen) {
            (5w0x0 &&& 5w0x0, 16w0x4000 &&& 16w0x4000, 8w0x0 &&& 8w0x0): parse_port_ids_2;
            (5w0x0 &&& 5w0x0, 16w0x1000 &&& 16w0x1000, 8w0x0 &&& 8w0x0): parse_q_occupancy_2;
            (5w0x0 &&& 5w0x0, 16w0x800 &&& 16w0x800, 8w0x0 &&& 8w0x0): parse_ingress_tstamp_2;
            (5w0x1 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x7 &&& 8w0xff): parse_int_tail;
            (5w0x2 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xa &&& 8w0xff): parse_int_tail;
            (5w0x3 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xd &&& 8w0xff): parse_int_tail;
            (5w0x4 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x10 &&& 8w0xff): parse_int_tail;
            (5w0x5 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x13 &&& 8w0xff): parse_int_tail;
            (5w0x6 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x16 &&& 8w0xff): parse_int_tail;
            (5w0x7 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x19 &&& 8w0xff): parse_int_tail;
            (5w0x8 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x1c &&& 8w0xff): parse_int_tail;
            (5w0x0 &&& 5w0x0, 16w0x8000 &&& 16w0x8000, 8w0x0 &&& 8w0x0): parse_switch_id_3;
            default: accept;
        }
    }
    @name(".parse_switch_id_3") state parse_switch_id_3 {
        packet.extract(hdr.int_switch_id_3);
        meta.md_netcope.hop3_vld = 1w1;
        transition select(meta.md_netcope.INTinscnt, meta.md_netcope.INTinsmap, meta.md_netcope.INTlen) {
            (5w0x0 &&& 5w0x0, 16w0x4000 &&& 16w0x4000, 8w0x0 &&& 8w0x0): parse_port_ids_3;
            (5w0x0 &&& 5w0x0, 16w0x1000 &&& 16w0x1000, 8w0x0 &&& 8w0x0): parse_q_occupancy_3;
            (5w0x0 &&& 5w0x0, 16w0x800 &&& 16w0x800, 8w0x0 &&& 8w0x0): parse_ingress_tstamp_3;
            (5w0x1 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x8 &&& 8w0xff): parse_int_tail;
            (5w0x2 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xc &&& 8w0xff): parse_int_tail;
            (5w0x3 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x10 &&& 8w0xff): parse_int_tail;
            (5w0x4 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x14 &&& 8w0xff): parse_int_tail;
            (5w0x5 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x18 &&& 8w0xff): parse_int_tail;
            (5w0x6 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x1c &&& 8w0xff): parse_int_tail;
            (5w0x7 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x20 &&& 8w0xff): parse_int_tail;
            (5w0x8 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x24 &&& 8w0xff): parse_int_tail;
            (5w0x0 &&& 5w0x0, 16w0x8000 &&& 16w0x8000, 8w0x0 &&& 8w0x0): parse_switch_id_5;
            default: accept;
        }
    }
    @name(".parse_switch_id_4") state parse_switch_id_4 {
        packet.extract(hdr.int_switch_id_4);
        meta.md_netcope.hop4_vld = 1w1;
        transition select(meta.md_netcope.INTinscnt, meta.md_netcope.INTinsmap, meta.md_netcope.INTlen) {
            (5w0x0 &&& 5w0x0, 16w0x4000 &&& 16w0x4000, 8w0x0 &&& 8w0x0): parse_port_ids_4;
            (5w0x0 &&& 5w0x0, 16w0x1000 &&& 16w0x1000, 8w0x0 &&& 8w0x0): parse_q_occupancy_4;
            (5w0x0 &&& 5w0x0, 16w0x800 &&& 16w0x800, 8w0x0 &&& 8w0x0): parse_ingress_tstamp_4;
            (5w0x1 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x9 &&& 8w0xff): parse_int_tail;
            (5w0x2 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xe &&& 8w0xff): parse_int_tail;
            (5w0x3 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x13 &&& 8w0xff): parse_int_tail;
            (5w0x4 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x18 &&& 8w0xff): parse_int_tail;
            (5w0x5 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x1d &&& 8w0xff): parse_int_tail;
            (5w0x6 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x22 &&& 8w0xff): parse_int_tail;
            (5w0x7 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x27 &&& 8w0xff): parse_int_tail;
            (5w0x8 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x2c &&& 8w0xff): parse_int_tail;
            (5w0x0 &&& 5w0x0, 16w0x8000 &&& 16w0x8000, 8w0x0 &&& 8w0x0): parse_switch_id_5;
            default: accept;
        }
    }
    @name(".parse_switch_id_5") state parse_switch_id_5 {
        packet.extract(hdr.int_switch_id_5);
        meta.md_netcope.hop5_vld = 1w1;
        transition select(meta.md_netcope.INTinscnt, meta.md_netcope.INTinsmap, meta.md_netcope.INTlen) {
            (5w0x0 &&& 5w0x0, 16w0x4000 &&& 16w0x4000, 8w0x0 &&& 8w0x0): parse_port_ids_5;
            (5w0x0 &&& 5w0x0, 16w0x1000 &&& 16w0x1000, 8w0x0 &&& 8w0x0): parse_q_occupancy_5;
            (5w0x0 &&& 5w0x0, 16w0x800 &&& 16w0x800, 8w0x0 &&& 8w0x0): parse_ingress_tstamp_5;
            (5w0x1 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x9 &&& 8w0xff): parse_int_tail;
            (5w0x2 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xe &&& 8w0xff): parse_int_tail;
            (5w0x3 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x13 &&& 8w0xff): parse_int_tail;
            (5w0x4 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x18 &&& 8w0xff): parse_int_tail;
            (5w0x5 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x1d &&& 8w0xff): parse_int_tail;
            (5w0x6 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x22 &&& 8w0xff): parse_int_tail;
            (5w0x7 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x27 &&& 8w0xff): parse_int_tail;
            (5w0x8 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x2c &&& 8w0xff): parse_int_tail;
            default: accept;
        }
    }
    @name(".parse_tcp") state parse_tcp {
        packet.extract(hdr.tcp);
        meta.md_netcope.L4src = hdr.tcp.srcPort;
        meta.md_netcope.L4dst = hdr.tcp.dstPort;
        meta.md_netcope.L4proto = 8w0x6;
        transition select(meta.internal_metadata.dscp) {
            6w0x1: parse_int_shim;
            default: accept;
        }
    }
    @name(".parse_udp") state parse_udp {
        packet.extract(hdr.udp);
        meta.md_netcope.L4src = hdr.udp.srcPort;
        meta.md_netcope.L4dst = hdr.udp.dstPort;
        meta.md_netcope.L4proto = 8w0x11;
        transition select(meta.internal_metadata.dscp, hdr.udp.dstPort) {
            (6w0 &&& 6w0x0, 16w2152 &&& 16w0xffff): parse_gtp;
            (6w0x1 &&& 6w0x3f, 16w0x0 &&& 16w0x0): parse_int_shim;
            default: accept;
        }
    }
    @name(".start") state start {
        meta.md_netcope.valid_int = 1w0;
        meta.md_netcope.hop0_vld = 1w0;
        meta.md_netcope.hop1_vld = 1w0;
        meta.md_netcope.hop2_vld = 1w0;
        meta.md_netcope.hop3_vld = 1w0;
        meta.md_netcope.hop4_vld = 1w0;
        meta.md_netcope.hop5_vld = 1w0;
        transition parse_ethernet;
    }
}

control ingress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @name(".permit") action permit() {
        ;
    }
    @name(".act_remove_int") action act_remove_int() {
        hdr.int_shim.setInvalid();
        hdr.int_tail.setInvalid();
        hdr.int_header.setInvalid();
        hdr.int_switch_id_0.setInvalid();
        hdr.int_port_ids_0.setInvalid();
        hdr.int_q_occupancy_0.setInvalid();
        hdr.int_ingress_tstamp_0.setInvalid();
        hdr.int_switch_id_1.setInvalid();
        hdr.int_port_ids_1.setInvalid();
        hdr.int_q_occupancy_1.setInvalid();
        hdr.int_ingress_tstamp_1.setInvalid();
        hdr.int_switch_id_2.setInvalid();
        hdr.int_port_ids_2.setInvalid();
        hdr.int_q_occupancy_2.setInvalid();
        hdr.int_ingress_tstamp_2.setInvalid();
        hdr.int_switch_id_3.setInvalid();
        hdr.int_port_ids_3.setInvalid();
        hdr.int_q_occupancy_3.setInvalid();
        hdr.int_ingress_tstamp_3.setInvalid();
        hdr.int_switch_id_5.setInvalid();
        hdr.int_port_ids_5.setInvalid();
        hdr.int_q_occupancy_5.setInvalid();
        hdr.int_ingress_tstamp_5.setInvalid();
    }
    @name(".drop_packet") action drop_packet() {
        mark_to_drop();
    }
    @name(".send_to_dma") action send_to_dma() {
        standard_metadata.egress_port = 9w128;
    }
    @name(".send_to_eth") action send_to_eth() {
        standard_metadata.egress_port = 9w0;
    }
    @name(".send_to_port") action send_to_port(bit<9> port) {
        standard_metadata.egress_port = port;
    }
    @name(".terminate_gtp") action terminate_gtp() {
        hdr.gtp.setInvalid();
        hdr.udp.setInvalid();
        hdr.ipv4.setInvalid();
    }
    @name(".update_L4") action update_L4() {
        hdr.ipv4.protocol = hdr.int_tail.next_proto;
        hdr.ipv4.dscp = (bit<6>)hdr.int_tail.dscp;
        hdr.udp.dstPort = hdr.int_tail.dest_port;
        hdr.tcp.dstPort = hdr.int_tail.dest_port;
        meta.md_netcope.L4proto = hdr.int_tail.next_proto;
        meta.md_netcope.L4dst = hdr.int_tail.dest_port;
        meta.internal_metadata.INTlenB = (bit<10>)meta.md_netcope.INTlen;
        meta.internal_metadata.INTlenB = meta.internal_metadata.INTlenB + (bit<10>)meta.md_netcope.INTlen;
        meta.internal_metadata.INTlenB = meta.internal_metadata.INTlenB + (bit<10>)meta.md_netcope.INTlen;
        meta.internal_metadata.INTlenB = meta.internal_metadata.INTlenB + (bit<10>)meta.md_netcope.INTlen;
        hdr.ipv4.totalLen = hdr.ipv4.totalLen - (bit<16>)meta.internal_metadata.INTlenB;
        hdr.udp.len = hdr.udp.len - (bit<16>)meta.internal_metadata.INTlenB;
        hash(hdr.ipv4.hdrChecksum, 
	     HashAlgorithm.csum16, 
	     (bit<16>)0, 
	      { hdr.ipv4.version, 
		hdr.ipv4.ihl, 
	 	hdr.ipv4.dscp, 
		hdr.ipv4.ecn, 
		hdr.ipv4.totalLen, 
		hdr.ipv4.id, 
		hdr.ipv4.flags, 
		hdr.ipv4.fragOffset,
		hdr.ipv4.ttl, 
		hdr.ipv4.protocol, 
		hdr.ipv4.srcAddr, 
		hdr.ipv4.dstAddr }, 
	     (bit<32>)65536);
        hdr.udp.csum = 16w0;
        hdr.tcp.csum = 16w0;
    }
    @name(".update_enc_L4") action update_enc_L4() {
        hdr.enc_ipv4.protocol = hdr.int_tail.next_proto;
        hdr.enc_ipv4.dscp = (bit<6>)hdr.int_tail.dscp;
        hdr.enc_udp.dstPort = hdr.int_tail.dest_port;
        hdr.tcp.dstPort = hdr.int_tail.dest_port;
        meta.md_netcope.L4proto = hdr.int_tail.next_proto;
        meta.md_netcope.L4dst = hdr.int_tail.dest_port;
        meta.internal_metadata.INTlenB = (bit<10>)meta.md_netcope.INTlen;
        meta.internal_metadata.INTlenB = meta.internal_metadata.INTlenB + (bit<10>)meta.md_netcope.INTlen;
        meta.internal_metadata.INTlenB = meta.internal_metadata.INTlenB + (bit<10>)meta.md_netcope.INTlen;
        meta.internal_metadata.INTlenB = meta.internal_metadata.INTlenB + (bit<10>)meta.md_netcope.INTlen;
        hdr.ipv4.totalLen = hdr.ipv4.totalLen - (bit<16>)meta.internal_metadata.INTlenB;
        hdr.udp.len = hdr.udp.len - (bit<16>)meta.internal_metadata.INTlenB;
        hdr.enc_ipv4.totalLen = hdr.enc_ipv4.totalLen - (bit<16>)meta.internal_metadata.INTlenB;
        hdr.enc_udp.len = hdr.enc_udp.len - (bit<16>)meta.internal_metadata.INTlenB;
        hash(hdr.ipv4.hdrChecksum, 
	     HashAlgorithm.csum16, 
	     (bit<16>)0, 
	     {  hdr.ipv4.version, 
	        hdr.ipv4.ihl, 
	        hdr.ipv4.dscp, 
		hdr.ipv4.ecn, 
		hdr.ipv4.totalLen, 
	  	hdr.ipv4.id, 
		hdr.ipv4.flags, 
		hdr.ipv4.fragOffset, 
		hdr.ipv4.ttl, 
		hdr.ipv4.protocol, 
		hdr.ipv4.srcAddr, 
		hdr.ipv4.dstAddr}, 
	     (bit<32>)65536);
        hash(hdr.enc_ipv4.hdrChecksum, 
	     HashAlgorithm.csum16, 
	     (bit<16>)0, 
	     {  hdr.enc_ipv4.version, 
		hdr.enc_ipv4.ihl, 
		hdr.enc_ipv4.dscp, 
		hdr.enc_ipv4.ecn, 
		hdr.enc_ipv4.totalLen, 
		hdr.enc_ipv4.id, 
		hdr.enc_ipv4.flags, 
		hdr.enc_ipv4.fragOffset, 
		hdr.enc_ipv4.ttl, 
		hdr.enc_ipv4.protocol, 
		hdr.enc_ipv4.srcAddr, 
		hdr.enc_ipv4.dstAddr}, 
	     (bit<32>)65536);
        hdr.udp.csum = 16w0;
        hdr.tcp.csum = 16w0;
        hdr.enc_udp.csum = 16w0;
    }
    @name(".tab_remove_int") table tab_remove_int {
        actions = {
            permit;
            act_remove_int;
            drop_packet;
        }
    }
    @name(".tab_send") table tab_send {
        actions = {
            permit;
            send_to_dma;
            send_to_eth;
            send_to_port;
        }
    }
    @name(".tab_terminate_gtp") table tab_terminate_gtp {
        actions = {
            permit;
            terminate_gtp;
        }
    }
    @name(".tab_update_L4") table tab_update_L4 {
        actions = {
            permit;
            update_L4;
        }
    }
    @name(".tab_update_enc_L4") table tab_update_enc_L4 {
        actions = {
            permit;
            update_enc_L4;
        }
    }
    apply @core_identification("Netcope-P4-INT-sink-2.0") {
        if (hdr.int_tail.isValid()) {
            tab_remove_int.apply();
            if (hdr.gtp.isValid()) {
                tab_update_enc_L4.apply();
            }
            else {
                tab_update_L4.apply();
            }
        }
        if (hdr.gtp.isValid()) {
            tab_terminate_gtp.apply();
        }
        tab_send.apply();
    }
}

control egress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    apply {
    }
}

control DeparserImpl(packet_out packet, in headers hdr) {
    apply {
        packet.emit(hdr.ethernet);
        packet.emit(hdr.ipv4);
        packet.emit(hdr.udp);
        packet.emit(hdr.gtp);
        packet.emit(hdr.enc_ipv4);
        packet.emit(hdr.tcp);
        packet.emit(hdr.enc_udp);
        packet.emit(hdr.int_shim);
        packet.emit(hdr.int_header);
        packet.emit(hdr.int_switch_id_0);
        packet.emit(hdr.int_port_ids_0);
        packet.emit(hdr.int_q_occupancy_0);
        packet.emit(hdr.int_ingress_tstamp_0);
        packet.emit(hdr.int_switch_id_1);
        packet.emit(hdr.int_port_ids_1);
        packet.emit(hdr.int_q_occupancy_1);
        packet.emit(hdr.int_ingress_tstamp_1);
        packet.emit(hdr.int_switch_id_2);
        packet.emit(hdr.int_port_ids_2);
        packet.emit(hdr.int_q_occupancy_2);
        packet.emit(hdr.int_ingress_tstamp_2);
        packet.emit(hdr.int_switch_id_3);
        packet.emit(hdr.int_port_ids_3);
        packet.emit(hdr.int_q_occupancy_3);
        packet.emit(hdr.int_ingress_tstamp_3);
        packet.emit(hdr.int_switch_id_5);
        packet.emit(hdr.int_port_ids_5);
        packet.emit(hdr.int_q_occupancy_5);
        packet.emit(hdr.int_ingress_tstamp_5);
        packet.emit(hdr.int_egress_tstamp_5);
        packet.emit(hdr.int_tail);
    }
}

control verifyChecksum(inout headers hdr, inout metadata meta) {
    apply {
    }
}

control computeChecksum(inout headers hdr, inout metadata meta) {
    apply {
    }
}

V1Switch(ParserImpl(), verifyChecksum(), ingress(), egress(), computeChecksum(), DeparserImpl()) main;

