#include <core.p4>
#include <v1model.p4>
#include "headers.p4"
#include "parser.p4"

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

V1Switch(ParserImpl(), verifyChecksum(), ingress(), egress(), computeChecksum(), DeparserImpl()) main;

