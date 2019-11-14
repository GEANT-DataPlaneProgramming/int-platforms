//#include <core.p4>
//#include <v1model.p4>

#include "headers.p4"
#include "parser.p4"

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
		standard_metadata.egress_spec = port;
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

V1Switch(ParserImpl(), verifyChecksum(), ingress(), egress(), computeChecksum(), DeparserImpl()) main;

