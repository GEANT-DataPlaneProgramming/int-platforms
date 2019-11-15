//#include <core.p4>
//#include <v1model.p4>

#include "headers.p4"
#include "parser.p4"

control Int_processing(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {

    @name(".int_update_ipv4_ac") action int_update_ipv4_ac() {
        hdr.ipv4.totalLen = hdr.ipv4.totalLen + (bit<16>)meta.int_metadata.insert_byte_cnt;
    }
    @name(".int_update_shim_ac") action int_update_shim_ac() {
        hdr.int_shim.len = hdr.int_shim.len + (bit<8>)meta.int_metadata.int_hdr_word_len;
    }
    @name(".int_update_udp_ac") action int_update_udp_ac() {
        hdr.udp.len = hdr.udp.len + (bit<16>)meta.int_metadata.insert_byte_cnt;
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
	
	
    @name(".int_transit") action int_transit(bit<32> switch_id, bit<16> l3_mtu) {
        meta.int_metadata.switch_id = switch_id;
        meta.int_metadata.insert_byte_cnt = (bit<16>) hdr.int_header.hop_metadata_len << 2;
        meta.int_metadata.int_hdr_word_len = (bit<8>) hdr.int_header.hop_metadata_len;
		meta.layer34_metadata.l3_mtu = l3_mtu;
    }
	action int_hop_cnt_decrement() {
		hdr.int_header.remaining_hop_cnt = hdr.int_header.remaining_hop_cnt - 1;
	}
	
	@name(".int_set_header_0") action int_set_header_0() {
        hdr.int_switch_id.setValid();
        hdr.int_switch_id.switch_id = meta.int_metadata.switch_id;
    }
	@name(".int_set_header_1") action int_set_header_1() {
        hdr.int_port_ids.setValid();
        hdr.int_port_ids.ingress_port_id = (bit<16>)standard_metadata.ingress_port;
        hdr.int_port_ids.egress_port_id = (bit<16>)standard_metadata.egress_port;
    }
    @name(".int_set_header_3") action int_set_header_3() {
        hdr.int_q_occupancy.setValid();
        hdr.int_q_occupancy.q_id = 8w0;
        hdr.int_q_occupancy.q_occupancy = 24w2;
    }
	@name(".int_set_header_4") action int_set_header_4() {
        hdr.int_ingress_tstamp.setValid();
        hdr.int_ingress_tstamp.ingress_tstamp = (bit<32>)meta.intrinsic_metadata.ingress_timestamp;
    }
	@name(".int_set_header_5") action int_set_header_5() {
        hdr.int_egress_tstamp.setValid();
        hdr.int_egress_tstamp.egress_tstamp = (bit<32>)meta.intrinsic_metadata.ingress_timestamp;
        hdr.int_egress_tstamp.egress_tstamp = hdr.int_egress_tstamp.egress_tstamp + 32w1;
    }
	
    @name(".int_set_header_0003_i0") action int_set_header_0003_i0() {
        ;
    }
    @name(".int_set_header_0003_i1") action int_set_header_0003_i1() {
        int_set_header_3();
    }
    @name(".int_set_header_0003_i4") action int_set_header_0003_i4() {
        int_set_header_1();
    }
    @name(".int_set_header_0003_i5") action int_set_header_0003_i5() {
        int_set_header_3();
        int_set_header_1();
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
    @name(".int_set_header_0407_i4") action int_set_header_0407_i4() {
        int_set_header_5();
    }
    @name(".int_set_header_0407_i8") action int_set_header_0407_i8() {
        int_set_header_4();
    }
    @name(".int_set_header_0407_i12") action int_set_header_0407_i12() {
        int_set_header_5();
        int_set_header_4();
    }
    @name(".int_source") action int_source(bit<8> max_hop, bit<5> ins_cnt, bit<16> ins_mask) {
        hdr.int_shim.setValid();
        hdr.int_shim.int_type = 8w1;
        hdr.int_shim.len = 8w4;
        hdr.int_header.setValid();
        hdr.int_header.ver = 4w1;
        hdr.int_header.rep = 2w0;
        hdr.int_header.c = 1w0;
        hdr.int_header.e = 1w0;
		hdr.int_header.m = 1w0;
        hdr.int_header.rsvd1 = 7w0;
		hdr.int_header.rsvd2 = 3w0;
        hdr.int_header.remaining_hop_cnt = max_hop;
        hdr.int_header.hop_metadata_len = ins_cnt;
        hdr.int_header.instruction_mask = ins_mask;
		hdr.int_header.rsvd3= 16w0;
        hdr.ipv4.totalLen = hdr.ipv4.totalLen + 16w12;
        hdr.udp.len = hdr.udp.len + 16w12;
    }
	
	@name(".int_source_dscp") action int_source_dscp(bit<8> max_hop, bit<5> ins_cnt, bit<16> ins_map) {
        int_source(max_hop, ins_cnt, ins_map);
        hdr.ipv4.dscp = 6w0x20;
    }
    @name(".int_set_sink") action int_set_sink() {
        meta.int_metadata.sink = 1w1;
    }
    @name(".int_set_source") action int_set_source() {
        meta.int_metadata.source = 1w1;
    }
	
	action int_hop_exceeded() {
        hdr.int_header.e = 1w1;
    }
	
	action int_mtu_limit_hit() {
        hdr.int_header.m = 1w1;
    }

    @name(".tab_set_egress") table tab_set_egress {
        actions = {
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
            hdr.int_header.instruction_mask: ternary;
        }
		const entries = {
			0x00 &&& 0xF0 : int_set_header_0003_i0();
			0x10 &&& 0xF0 : int_set_header_0003_i1();
			0x40 &&& 0xF0 : int_set_header_0003_i4();
			0x50 &&& 0xF0 : int_set_header_0003_i5();
			0x80 &&& 0xF0 : int_set_header_0003_i8();
			0x90 &&& 0xF0 : int_set_header_0003_i9();
			0xC0 &&& 0xF0 : int_set_header_0003_i12();
			0xD0 &&& 0xF0 : int_set_header_0003_i13();
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
            hdr.int_header.instruction_mask: ternary;
        }
		const entries = {
			0x00 &&& 0x0F : int_set_header_0407_i0();
			0x04 &&& 0x0F : int_set_header_0407_i4();
			0x08 &&& 0x0F : int_set_header_0407_i8();
			0x0C &&& 0x0F : int_set_header_0407_i12();
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
            meta.layer34_metadata.l4_src: ternary;
            meta.layer34_metadata.l4_dst: ternary;
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

    apply {	
		tab_set_egress.apply();
        tb_set_source.apply();
        tb_set_sink.apply();
		
		if (meta.int_metadata.source == 1w1)
			tb_int_source.apply();
		
		//TODO: check if hop-by-hop INT or destination INT
		
		if (!hdr.int_header.isValid())
			return;
		
		if (hdr.int_header.remaining_hop_cnt == 0 || hdr.int_header.e == 1) {
			int_hop_exceeded();
			return;
		}
		
		if (hdr.ipv4.totalLen + meta.int_metadata.insert_byte_cnt > meta.layer34_metadata.l3_mtu)
			int_mtu_limit_hit();

		if (meta.int_metadata.source == 1w0) 
			int_hop_cnt_decrement();

		tb_int_insert.apply();
		tb_int_inst_0003.apply();
		tb_int_inst_0407.apply();
		
		int_update_ipv4_ac();

		if (hdr.udp.isValid())
			int_update_udp_ac();

		if (hdr.int_shim.isValid()) 
			int_update_shim_ac();
    }
}

control ingress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
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
	
	@name(".tab_add_gtp_to_tcp") table tab_add_gtp_to_tcp {
        actions = {
            add_gtp_to_tcp;
        }
    }
    @name(".tab_add_gtp_to_udp") table tab_add_gtp_to_udp {
        actions = {
            add_gtp_to_udp;
        }
    }
	
	Int_processing() int_processing;
	
	apply @core_identification("P4-INT-2.0") {	
		if (!hdr.udp.isValid() && !hdr.tcp.isValid())
			exit;
		
		int_processing.apply(hdr, meta, standard_metadata);
		
		if (hdr.gtp.isValid()) {
			if (hdr.udp.isValid()) 
				  tab_add_gtp_to_udp.apply();

			if (hdr.tcp.isValid())
				tab_add_gtp_to_tcp.apply();
		}
	}
}

V1Switch(ParserImpl(), verifyChecksum(), ingress(), egress(), computeChecksum(), DeparserImpl()) main;

