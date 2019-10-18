#include <core.p4>
#include <v1model.p4>
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

