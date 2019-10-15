#include <core.p4>
#include <v1model.p4>

struct int_meta_t {
    bit<1>  source;
    bit<1>  sink;
    bit<32> switch_id;
    bit<7>  insert_byte_cnt;
}

struct internal_metadata_t {
    bit<6>  dscp;
    bit<10> INTlenB;
}

struct intrinsic_metadata_t {
    bit<48> ingress_timestamp;
}

struct netcope_metadata_t {
    bit<1>  valid_int;
    bit<1>  hop0_vld;
    bit<1>  hop1_vld;
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
    @name(".int_meta") 
    int_meta_t           int_meta;
    @name(".internal_metadata") 
    internal_metadata_t  internal_metadata;
    @name(".intrinsic_metadata") 
    intrinsic_metadata_t intrinsic_metadata;
    @name(".md_netcope") 
    netcope_metadata_t   md_netcope;
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
    @name(".int_egress_tstamp_0") 
    int_egress_tstamp_t       int_egress_tstamp_0;
    @name(".int_egress_tstamp_1") 
    int_egress_tstamp_t       int_egress_tstamp_1;
    @name(".int_header") 
    int_header_v0_5_t         int_header;
    @name(".int_hop_latency_0") 
    int_hop_latency_t         int_hop_latency_0;
    @name(".int_hop_latency_1") 
    int_hop_latency_t         int_hop_latency_1;
    @name(".int_ingress_tstamp_0") 
    int_ingress_tstamp_t      int_ingress_tstamp_0;
    @name(".int_ingress_tstamp_1") 
    int_ingress_tstamp_t      int_ingress_tstamp_1;
    @name(".int_port_ids_0") 
    int_port_ids_t            int_port_ids_0;
    @name(".int_port_ids_1") 
    int_port_ids_t            int_port_ids_1;
    @name(".int_q_congestion_0") 
    int_q_congestion_t        int_q_congestion_0;
    @name(".int_q_congestion_1") 
    int_q_congestion_t        int_q_congestion_1;
    @name(".int_q_occupancy_0") 
    int_q_occupancy_t         int_q_occupancy_0;
    @name(".int_q_occupancy_1") 
    int_q_occupancy_t         int_q_occupancy_1;
    @name(".int_shim") 
    intl4_shim_t              int_shim;
    @name(".int_switch_id_0") 
    int_switch_id_t           int_switch_id_0;
    @name(".int_switch_id_1") 
    int_switch_id_t           int_switch_id_1;
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
            (5w0x0 &&& 5w0x0, 16w0x400 &&& 16w0x400, 8w0x0 &&& 8w0x0): parse_egress_tstamp_1;
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
            (5w0x0 &&& 5w0x0, 16w0x400 &&& 16w0x400, 8w0x0 &&& 8w0x0): parse_egress_tstamp_1;
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
            6w0x20: parse_int_shim;
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
            (5w0x0 &&& 5w0x0, 16w0x400 &&& 16w0x400, 8w0x0 &&& 8w0x0): parse_egress_tstamp_0;
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
            (5w0x0 &&& 5w0x0, 16w0x400 &&& 16w0x400, 8w0x0 &&& 8w0x0): parse_egress_tstamp_1;
            (5w0x1 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x6 &&& 8w0xff): parse_int_tail;
            (5w0x2 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x8 &&& 8w0xff): parse_int_tail;
            (5w0x3 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xa &&& 8w0xff): parse_int_tail;
            (5w0x4 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xc &&& 8w0xff): parse_int_tail;
            (5w0x5 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xe &&& 8w0xff): parse_int_tail;
            (5w0x6 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x10 &&& 8w0xff): parse_int_tail;
            (5w0x7 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x12 &&& 8w0xff): parse_int_tail;
            (5w0x8 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x14 &&& 8w0xff): parse_int_tail;
            default: accept;
        }
    }
    @name(".parse_ingress_tstamp_0") state parse_ingress_tstamp_0 {
        packet.extract(hdr.int_ingress_tstamp_0);
        meta.md_netcope.hop0_vld = 1w1;
        transition select(meta.md_netcope.INTinscnt, meta.md_netcope.INTinsmap, meta.md_netcope.INTlen) {
            (5w0x0 &&& 5w0x0, 16w0x400 &&& 16w0x400, 8w0x0 &&& 8w0x0): parse_egress_tstamp_0;
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
            (5w0x0 &&& 5w0x0, 16w0x400 &&& 16w0x400, 8w0x0 &&& 8w0x0): parse_egress_tstamp_1;
            (5w0x1 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x6 &&& 8w0xff): parse_int_tail;
            (5w0x2 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x8 &&& 8w0xff): parse_int_tail;
            (5w0x3 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xa &&& 8w0xff): parse_int_tail;
            (5w0x4 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xc &&& 8w0xff): parse_int_tail;
            (5w0x5 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xe &&& 8w0xff): parse_int_tail;
            (5w0x6 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x10 &&& 8w0xff): parse_int_tail;
            (5w0x7 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x12 &&& 8w0xff): parse_int_tail;
            (5w0x8 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x14 &&& 8w0xff): parse_int_tail;
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
            (5w0x0 &&& 5w0x0, 16w0x400 &&& 16w0x400, 8w0x0 &&& 8w0x0): parse_egress_tstamp_0;
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
            (5w0x0 &&& 5w0x0, 16w0x400 &&& 16w0x400, 8w0x0 &&& 8w0x0): parse_egress_tstamp_0;
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
            (5w0x0 &&& 5w0x0, 16w0x400 &&& 16w0x400, 8w0x0 &&& 8w0x0): parse_egress_tstamp_1;
            (5w0x1 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x6 &&& 8w0xff): parse_int_tail;
            (5w0x2 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x8 &&& 8w0xff): parse_int_tail;
            (5w0x3 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xa &&& 8w0xff): parse_int_tail;
            (5w0x4 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xc &&& 8w0xff): parse_int_tail;
            (5w0x5 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xe &&& 8w0xff): parse_int_tail;
            (5w0x6 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x10 &&& 8w0xff): parse_int_tail;
            (5w0x7 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x12 &&& 8w0xff): parse_int_tail;
            (5w0x8 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x14 &&& 8w0xff): parse_int_tail;
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
            (5w0x0 &&& 5w0x0, 16w0x400 &&& 16w0x400, 8w0x0 &&& 8w0x0): parse_egress_tstamp_1;
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
            default: accept;
        }
    }
    @name(".parse_q_occupancy_0") state parse_q_occupancy_0 {
        packet.extract(hdr.int_q_occupancy_0);
        meta.md_netcope.hop0_vld = 1w1;
        transition select(meta.md_netcope.INTinscnt, meta.md_netcope.INTinsmap, meta.md_netcope.INTlen) {
            (5w0x0 &&& 5w0x0, 16w0x800 &&& 16w0x800, 8w0x0 &&& 8w0x0): parse_ingress_tstamp_0;
            (5w0x0 &&& 5w0x0, 16w0x400 &&& 16w0x400, 8w0x0 &&& 8w0x0): parse_egress_tstamp_0;
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
            (5w0x0 &&& 5w0x0, 16w0x400 &&& 16w0x400, 8w0x0 &&& 8w0x0): parse_egress_tstamp_1;
            (5w0x1 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x6 &&& 8w0xff): parse_int_tail;
            (5w0x2 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x8 &&& 8w0xff): parse_int_tail;
            (5w0x3 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xa &&& 8w0xff): parse_int_tail;
            (5w0x4 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xc &&& 8w0xff): parse_int_tail;
            (5w0x5 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xe &&& 8w0xff): parse_int_tail;
            (5w0x6 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x10 &&& 8w0xff): parse_int_tail;
            (5w0x7 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x12 &&& 8w0xff): parse_int_tail;
            (5w0x8 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x14 &&& 8w0xff): parse_int_tail;
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
            (5w0x0 &&& 5w0x0, 16w0x400 &&& 16w0x400, 8w0x0 &&& 8w0x0): parse_egress_tstamp_0;
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
            (5w0x0 &&& 5w0x0, 16w0x400 &&& 16w0x400, 8w0x0 &&& 8w0x0): parse_egress_tstamp_1;
            (5w0x1 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x6 &&& 8w0xff): parse_int_tail;
            (5w0x2 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x8 &&& 8w0xff): parse_int_tail;
            (5w0x3 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xa &&& 8w0xff): parse_int_tail;
            (5w0x4 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xc &&& 8w0xff): parse_int_tail;
            (5w0x5 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0xe &&& 8w0xff): parse_int_tail;
            (5w0x6 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x10 &&& 8w0xff): parse_int_tail;
            (5w0x7 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x12 &&& 8w0xff): parse_int_tail;
            (5w0x8 &&& 5w0x1f, 16w0x0 &&& 16w0x0, 8w0x14 &&& 8w0xff): parse_int_tail;
            default: accept;
        }
    }
    @name(".parse_tcp") state parse_tcp {
        packet.extract(hdr.tcp);
        meta.md_netcope.L4src = hdr.tcp.srcPort;
        meta.md_netcope.L4dst = hdr.tcp.dstPort;
        meta.md_netcope.L4proto = 8w0x6;
        transition select(meta.internal_metadata.dscp) {
            6w0x20: parse_int_shim;
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
            (6w0x20 &&& 6w0x3f, 16w0x0 &&& 16w0x0): parse_int_shim;
            default: accept;
        }
    }
    @name(".start") state start {
        meta.md_netcope.valid_int = 1w0;
        meta.md_netcope.hop0_vld = 1w0;
        meta.md_netcope.hop1_vld = 1w0;
        transition parse_ethernet;
    }
}

control ingress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @name(".int_update_ipv4_ac") action int_update_ipv4_ac() {
        hdr.ipv4.totalLen = hdr.ipv4.totalLen + (bit<16>)meta.int_meta.insert_byte_cnt;
    }
    @name(".int_update_shim_ac") action int_update_shim_ac() {
        hdr.int_shim.len = hdr.int_shim.len + (bit<8>)hdr.int_header.ins_cnt;
    }
    @name(".int_update_udp_ac") action int_update_udp_ac() {
        hdr.udp.len = hdr.udp.len + (bit<16>)meta.int_meta.insert_byte_cnt;
    }
    @name(".add_gtp") action add_gtp() {
        hdr.gtp.setValid();
        hdr.gtp.version = 3w1;
        hdr.gtp.protType = 1w0;
        hdr.gtp.reserved = 1w0;
        hdr.gtp.flags = 3w0;
        hdr.gtp.messageType = 8w0;
        hdr.gtp.messageLen = 16w0;
        hdr.gtp.teid = 32w0;
    }
    @name(".add_gtp_add_ipv4") action add_gtp_add_ipv4() {
        hdr.enc_ipv4.setValid();
        hdr.enc_ipv4.version = hdr.ipv4.version;
        hdr.enc_ipv4.ihl = hdr.ipv4.ihl;
        hdr.enc_ipv4.dscp = hdr.ipv4.dscp;
        hdr.enc_ipv4.ecn = hdr.ipv4.ecn;
        hdr.enc_ipv4.totalLen = hdr.ipv4.totalLen;
        hdr.enc_ipv4.id = hdr.ipv4.id;
        hdr.enc_ipv4.flags = hdr.ipv4.flags;
        hdr.enc_ipv4.fragOffset = hdr.ipv4.fragOffset;
        hdr.enc_ipv4.ttl = hdr.ipv4.ttl;
        hdr.enc_ipv4.protocol = hdr.ipv4.protocol;
        hdr.enc_ipv4.hdrChecksum = hdr.ipv4.hdrChecksum;
        hdr.enc_ipv4.srcAddr = hdr.ipv4.srcAddr;
        hdr.enc_ipv4.dstAddr = hdr.ipv4.dstAddr;
    }
    @name(".add_gtp_set_new_outer") action add_gtp_set_new_outer(bit<32> srcAddr, bit<32> dstAddr) {
        hdr.ipv4.protocol = 8w0x11;
        hdr.ipv4.version = 4w4;
        hdr.ipv4.ihl = 4w5;
        hdr.ipv4.dscp = 6w0;
        hdr.ipv4.ecn = 2w0;
        hdr.ipv4.totalLen = hdr.ipv4.totalLen + 16w36;
        hdr.ipv4.id = 16w0;
        hdr.ipv4.flags = 3w0;
        hdr.ipv4.fragOffset = 13w0;
        hdr.ipv4.ttl = 8w64;
        hdr.ipv4.hdrChecksum = 16w0;
        hdr.ipv4.srcAddr = srcAddr;
        hdr.ipv4.dstAddr = dstAddr;
        hdr.udp.setValid();
        hdr.udp.dstPort = 16w2152;
        hdr.udp.srcPort = 16w2152;
        hdr.udp.len = hdr.udp.len + 16w36;
        hdr.udp.csum = 16w0;
    }
    @name(".add_gtp_to_tcp") action add_gtp_to_tcp(bit<32> srcAddr, bit<32> dstAddr) {
        add_gtp();
        add_gtp_add_ipv4();
        hdr.udp.len = 16w0;
        add_gtp_set_new_outer(srcAddr, dstAddr);
        hdr.udp.len = hdr.udp.len + hdr.enc_ipv4.totalLen;
        hdr.udp.len = hdr.udp.len - 16w20;
    }
    @name(".permit") action permit() {
        ;
    }
    @name(".add_gtp_to_udp") action add_gtp_to_udp(bit<32> srcAddr, bit<32> dstAddr) {
        add_gtp();
        add_gtp_add_ipv4();
        hdr.enc_udp.setValid();
        hdr.enc_udp.srcPort = hdr.udp.srcPort;
        hdr.enc_udp.dstPort = hdr.udp.dstPort;
        hdr.enc_udp.len = hdr.udp.len;
        hdr.enc_udp.csum = hdr.udp.csum;
        add_gtp_set_new_outer(srcAddr, dstAddr);
    }
    @name(".send_to_cpu") action send_to_cpu() {
        standard_metadata.egress_port = 9w128;
    }
    @name(".send_to_eth") action send_to_eth() {
        standard_metadata.egress_port = 9w0;
    }
    @name(".send_to_port") action send_to_port(bit<9> port) {
        standard_metadata.egress_port = port;
    }
    @name(".int_transit") action int_transit(bit<32> switch_id) {
        meta.int_meta.switch_id = switch_id;
        meta.int_meta.insert_byte_cnt = (bit<7>)hdr.int_header.ins_cnt;
        meta.int_meta.insert_byte_cnt = meta.int_meta.insert_byte_cnt << 2;
    }
    @name(".int_set_header_0003_i0") action int_set_header_0003_i0() {
        ;
    }
    @name(".int_set_header_3") action int_set_header_3() {
        hdr.int_q_occupancy_0.setValid();
        hdr.int_q_occupancy_0.q_id = 8w0;
        hdr.int_q_occupancy_0.q_occupancy = 24w2;
    }
    @name(".int_set_header_0003_i1") action int_set_header_0003_i1() {
        int_set_header_3();
    }
    @name(".int_set_header_1") action int_set_header_1() {
        hdr.int_port_ids_0.setValid();
        hdr.int_port_ids_0.ingress_port_id = (bit<16>)standard_metadata.ingress_port;
        hdr.int_port_ids_0.egress_port_id = (bit<16>)standard_metadata.egress_port;
    }
    @name(".int_set_header_0003_i4") action int_set_header_0003_i4() {
        int_set_header_1();
    }
    @name(".int_set_header_0003_i5") action int_set_header_0003_i5() {
        int_set_header_3();
        int_set_header_1();
    }
    @name(".int_set_header_0") action int_set_header_0() {
        hdr.int_switch_id_0.setValid();
        hdr.int_switch_id_0.switch_id = meta.int_meta.switch_id;
    }
    @name(".int_set_header_0003_i8") action int_set_header_0003_i8() {
        int_set_header_0();
    }
    @name(".int_set_header_0003_i9") action int_set_header_0003_i9() {
        int_set_header_3();
        int_set_header_0();
    }
    @name(".int_set_header_0003_i12") action int_set_header_0003_i12() {
        int_set_header_1();
        int_set_header_0();
    }
    @name(".int_set_header_0003_i13") action int_set_header_0003_i13() {
        int_set_header_3();
        int_set_header_1();
        int_set_header_0();
    }
    @name(".int_set_header_0407_i0") action int_set_header_0407_i0() {
        ;
    }
    @name(".int_set_header_5") action int_set_header_5() {
        hdr.int_egress_tstamp_0.setValid();
        hdr.int_egress_tstamp_0.egress_tstamp = (bit<32>)meta.intrinsic_metadata.ingress_timestamp;
        hdr.int_egress_tstamp_0.egress_tstamp = hdr.int_egress_tstamp_0.egress_tstamp + 32w1;
    }
    @name(".int_set_header_0407_i4") action int_set_header_0407_i4() {
        int_set_header_5();
    }
    @name(".int_set_header_4") action int_set_header_4() {
        hdr.int_ingress_tstamp_0.setValid();
        hdr.int_ingress_tstamp_0.ingress_tstamp = (bit<32>)meta.intrinsic_metadata.ingress_timestamp;
    }
    @name(".int_set_header_0407_i8") action int_set_header_0407_i8() {
        int_set_header_4();
    }
    @name(".int_set_header_0407_i12") action int_set_header_0407_i12() {
        int_set_header_5();
        int_set_header_4();
    }
    @name(".int_source") action int_source(bit<8> max_hop, bit<5> ins_cnt, bit<16> ins_map) {
        hdr.int_shim.setValid();
        hdr.int_shim.int_type = 8w1;
        hdr.int_shim.len = 8w4;
        hdr.int_header.setValid();
        hdr.int_header.ver = 4w0;
        hdr.int_header.rep = 2w0;
        hdr.int_header.c = 1w0;
        hdr.int_header.e = 1w0;
        hdr.int_header.rsvd1 = 3w0;
        hdr.int_header.ins_cnt = ins_cnt;
        hdr.int_header.max_hop_count = max_hop;
        hdr.int_header.total_hop_count = 8w0;
        hdr.int_header.instruction_map = ins_map;
        hdr.int_tail.setValid();
        hdr.int_tail.next_proto = hdr.ipv4.protocol;
        hdr.int_tail.dest_port = meta.md_netcope.L4dst;
        hdr.int_tail.dscp = (bit<8>)hdr.ipv4.dscp;
        hdr.ipv4.totalLen = hdr.ipv4.totalLen + 16w16;
        hdr.udp.len = hdr.udp.len + 16w16;
    }
    @name(".int_source_dscp") action int_source_dscp(bit<8> max_hop, bit<5> ins_cnt, bit<16> ins_map) {
        int_source(max_hop, ins_cnt, ins_map);
        hdr.ipv4.dscp = 6w0x20;
    }
    @name(".int_set_sink") action int_set_sink() {
        meta.int_meta.sink = 1w1;
    }
    @name(".int_set_source") action int_set_source() {
        meta.int_meta.source = 1w1;
    }
    @name(".int_update_ipv4") table int_update_ipv4 {
        actions = {
            int_update_ipv4_ac;
        }
    }
    @name(".int_update_shim") table int_update_shim {
        actions = {
            int_update_shim_ac;
        }
    }
    @name(".int_update_udp") table int_update_udp {
        actions = {
            int_update_udp_ac;
        }
    }
    @name(".tab_add_gtp_to_tcp") table tab_add_gtp_to_tcp {
        actions = {
            add_gtp_to_tcp;
            permit;
        }
    }
    @name(".tab_add_gtp_to_udp") table tab_add_gtp_to_udp {
        actions = {
            add_gtp_to_udp;
            permit;
        }
    }
    @name(".tab_set_egress") table tab_set_egress {
        actions = {
            permit;
            send_to_cpu;
            send_to_eth;
            send_to_port;
        }
        key = {
            hdr.ethernet.dstAddr: ternary;
        }
        size = 31;
    }
    @name(".tb_int_insert") table tb_int_insert {
        actions = {
            int_transit;
        }
    }
    @name(".tb_int_inst_0003") table tb_int_inst_0003 {
        actions = {
            int_set_header_0003_i0;
            int_set_header_0003_i1;
            int_set_header_0003_i4;
            int_set_header_0003_i5;
            int_set_header_0003_i8;
            int_set_header_0003_i9;
            int_set_header_0003_i12;
            int_set_header_0003_i13;
        }
        key = {
            hdr.int_header.instruction_map: ternary;
        }
        size = 16;
    }
    @name(".tb_int_inst_0407") table tb_int_inst_0407 {
        actions = {
            int_set_header_0407_i0;
            int_set_header_0407_i4;
            int_set_header_0407_i8;
            int_set_header_0407_i12;
        }
        key = {
            hdr.int_header.instruction_map: ternary;
        }
        size = 16;
    }
    @name(".tb_int_source") table tb_int_source {
        actions = {
            int_source_dscp;
        }
        key = {
            hdr.ipv4.srcAddr     : ternary;
            hdr.ipv4.dstAddr     : ternary;
            meta.md_netcope.L4src: ternary;
            meta.md_netcope.L4dst: ternary;
        }
        size = 127;
    }
    @name(".tb_set_sink") table tb_set_sink {
        actions = {
            int_set_sink;
        }
        key = {
            standard_metadata.egress_port: exact;
        }
        size = 255;
    }
    @name(".tb_set_source") table tb_set_source {
        actions = {
            int_set_source;
        }
        key = {
            standard_metadata.ingress_port: exact;
        }
        size = 255;
    }
    apply @core_identification("Netcope-P4-INT-source-2.0") {
        tab_set_egress.apply();
        tb_set_source.apply();
        tb_set_sink.apply();
        if (hdr.udp.isValid() || hdr.tcp.isValid()) {
            if (meta.int_meta.source == 1w1) {
                tb_int_source.apply();
            }
            if (hdr.int_header.isValid()) {
                tb_int_insert.apply();
                tb_int_inst_0003.apply();
                tb_int_inst_0407.apply();
                if (hdr.ipv4.isValid()) {
                    int_update_ipv4.apply();
                }
                if (hdr.udp.isValid()) {
                    int_update_udp.apply();
                }
                if (hdr.int_shim.isValid()) {
                    int_update_shim.apply();
                }
            }
        }
        if (!hdr.gtp.isValid()) {
            if (hdr.udp.isValid()) {
                tab_add_gtp_to_udp.apply();
            }
            if (hdr.tcp.isValid()) {
                tab_add_gtp_to_tcp.apply();
            }
        }
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
        packet.emit(hdr.int_egress_tstamp_0);
        packet.emit(hdr.int_switch_id_1);
        packet.emit(hdr.int_port_ids_1);
        packet.emit(hdr.int_q_occupancy_1);
        packet.emit(hdr.int_ingress_tstamp_1);
        packet.emit(hdr.int_egress_tstamp_1);
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

