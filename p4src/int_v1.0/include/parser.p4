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

error
{
	INTShimLenTooShort,
	INTVersionNotSupported
}

#ifdef BMV2
parser ParserImpl(packet_in packet, out headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    state start {
       transition parse_ethernet;
    }
#elif TOFINO
parser IngressParser(packet_in packet, out headers hdr, out metadata meta, out ingress_intrinsic_metadata_t standard_metadata) {
    Checksum() ipv4_checksum;
    state start {
        packet.extract(standard_metadata);
        packet.advance(PORT_METADATA_SIZE);
        meta.int_metadata.mirror_type = 0;
        meta.int_metadata.session_ID = 1;
        meta.int_metadata.source = 0;
        meta.int_metadata.sink = 0;
        meta.int_metadata.switch_id = 0;
        meta.int_metadata.insert_byte_cnt = 0;
        meta.int_metadata.int_hdr_word_len = 0;
        meta.int_metadata.remove_int = 0;
        meta.int_metadata.sink_reporting_port = 0;
        /*meta.int_metadata.ingress_tstamp = 0;*/
        meta.int_metadata.ingress_port = 0;
/*        meta.int_metadata.instance_type = 0;*/
        meta.layer34_metadata.ip_src = 0;
        meta.layer34_metadata.ip_dst = 0;
        meta.layer34_metadata.ip_ver = 0;
        meta.layer34_metadata.l4_src = 0;
        meta.layer34_metadata.l4_dst = 0;
        meta.layer34_metadata.l4_proto = 0;
        meta.layer34_metadata.l3_mtu = 0;
        meta.layer34_metadata.dscp = 0;
        meta.int_len_bytes = 0;
        transition parse_ethernet;
    }
#endif

    state parse_ethernet {
        packet.extract(hdr.ethernet);
        transition select(hdr.ethernet.etherType) {
            16w0x800: parse_ipv4;
            default: accept;
        }
    }
    state parse_ipv4 {
        packet.extract(hdr.ipv4);
        meta.layer34_metadata.ip_src = hdr.ipv4.srcAddr;
        meta.layer34_metadata.ip_dst = hdr.ipv4.dstAddr;
        meta.layer34_metadata.ip_ver = 8w4;
        meta.layer34_metadata.dscp = hdr.ipv4.dscp;

        #ifdef TOFINO
        ipv4_checksum.add(hdr.ipv4);
        /*// Output of verify is 0 or 1*/
        /*// If it is 1, there is checksum error*/
        ipv4_checksum.verify();
        #endif
        transition select(hdr.ipv4.protocol) {
            8w0x11: parse_udp;
            8w0x6: parse_tcp;
            default: accept;
        }
    }
    state parse_tcp {
        packet.extract(hdr.tcp);
        meta.layer34_metadata.l4_src = hdr.tcp.srcPort;
        meta.layer34_metadata.l4_dst = hdr.tcp.dstPort;
        meta.layer34_metadata.l4_proto = 8w0x6;
        transition select(meta.layer34_metadata.dscp) {
            IPv4_DSCP_INT: parse_int;
            default: accept;
        }
    }
    state parse_udp {
        packet.extract(hdr.udp);
        meta.layer34_metadata.l4_src = hdr.udp.srcPort;
        meta.layer34_metadata.l4_dst = hdr.udp.dstPort;
        meta.layer34_metadata.l4_proto = 8w0x11;
        transition select(meta.layer34_metadata.dscp, hdr.udp.dstPort) {
            (6w0x20 &&& 6w0x3f, 16w0x0 &&& 16w0x0): parse_int;
            default: accept;
        }
    }
    state parse_int {
        packet.extract(hdr.int_shim);
        /*verify(hdr.int_shim.len >= 3, error.INTShimLenTooShort);*/
        packet.extract(hdr.int_header);
        // DAMU: warning (from TOFINO): Parser "verify" is currently unsupported
        /*verify(hdr.int_header.ver == INT_VERSION, error.INTVersionNotSupported);*/
        transition accept;
    }
}

#ifdef BMV2
control DeparserImpl(packet_out packet, in headers hdr) {
    apply {
        // raport headers
        packet.emit(hdr.report_ethernet);
        packet.emit(hdr.report_ipv4);
        packet.emit(hdr.report_udp);
        packet.emit(hdr.report_fixed_header);
        
        // original headers
        packet.emit(hdr.ethernet);
        packet.emit(hdr.ipv4);
        packet.emit(hdr.udp);
        packet.emit(hdr.tcp);
        
        // INT headers
        packet.emit(hdr.int_shim);
        packet.emit(hdr.int_header);
        
        // local INT node metadata
        packet.emit(hdr.int_switch_id);     //bit 1
        packet.emit(hdr.int_port_ids);       //bit 2
        packet.emit(hdr.int_hop_latency);   //bit 3
        packet.emit(hdr.int_q_occupancy);  // bit 4
        packet.emit(hdr.int_ingress_tstamp);  // bit 5
        packet.emit(hdr.int_egress_tstamp);   // bit 6
        packet.emit(hdr.int_level2_port_ids);   // bit 7
        packet.emit(hdr.int_egress_port_tx_util);  // bit 8
    }
}

control verifyChecksum(inout headers hdr, inout metadata meta) {
    apply {
    }
}

control computeChecksum(inout headers hdr, inout metadata meta) {
    apply {
        update_checksum(
            hdr.ipv4.isValid(),
            {
                hdr.ipv4.version,
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
                hdr.ipv4.dstAddr
            },
            hdr.ipv4.hdrChecksum,
            HashAlgorithm.csum16
        );
        
        update_checksum(
            hdr.report_ipv4.isValid(),
            {
                hdr.report_ipv4.version,
                hdr.report_ipv4.ihl,
                hdr.report_ipv4.dscp,
                hdr.report_ipv4.ecn,
                hdr.report_ipv4.totalLen,
                hdr.report_ipv4.id,
                hdr.report_ipv4.flags,
                hdr.report_ipv4.fragOffset,
                hdr.report_ipv4.ttl,
                hdr.report_ipv4.protocol,
                hdr.report_ipv4.srcAddr,
                hdr.report_ipv4.dstAddr
            },
            hdr.report_ipv4.hdrChecksum,
            HashAlgorithm.csum16
        );
        
        update_checksum_with_payload(
            hdr.udp.isValid(), 
            {  hdr.ipv4.srcAddr, 
                hdr.ipv4.dstAddr, 
                8w0, 
                hdr.ipv4.protocol, 
                hdr.udp.len, 
                hdr.udp.srcPort, 
                hdr.udp.dstPort, 
                hdr.udp.len 
            }, 
            hdr.udp.csum, 
            HashAlgorithm.csum16
        ); 

        update_checksum_with_payload(
            hdr.udp.isValid() && hdr.int_header.isValid() , 
            {  hdr.ipv4.srcAddr, 
                hdr.ipv4.dstAddr, 
                8w0, 
                hdr.ipv4.protocol, 
                hdr.udp.len, 
                hdr.udp.srcPort, 
                hdr.udp.dstPort, 
                hdr.udp.len,
                hdr.int_shim,
                hdr.int_header,
                hdr.int_switch_id,
                hdr.int_port_ids,
                hdr.int_q_occupancy,
                hdr.int_level2_port_ids,
                hdr.int_ingress_tstamp,
                hdr.int_egress_tstamp,
                hdr.int_egress_port_tx_util,
                hdr.int_hop_latency
            }, 
            hdr.udp.csum, 
            HashAlgorithm.csum16
        );
    }
}

#elif TOFINO
parser EgressParser(packet_in        pkt,
    /* User */
    out headers          hdr,
    out metadata         meta,
    /* Intrinsic */
    out egress_intrinsic_metadata_t  eg_intr_md)
{

    Checksum() ipv4_checksum;
    /* This is a mandatory state, required by Tofino Architecture */
    state start {
        pkt.extract(eg_intr_md);
        /* We reinitialize these to silence a compiler warning... */
        meta.int_metadata.mirror_type = 0;
        meta.int_metadata.session_ID = 1;
        meta.int_metadata.source = 0;
        meta.int_metadata.sink = 0;
        meta.int_metadata.switch_id = 0;
        meta.int_metadata.insert_byte_cnt = 0;
        meta.int_metadata.int_hdr_word_len = 0;
        meta.int_metadata.remove_int = 0;
        meta.int_metadata.sink_reporting_port = 0;
        meta.int_metadata.ingress_tstamp = 0;
        meta.int_metadata.ingress_port = 0;
        meta.layer34_metadata.ip_src = 0;
        meta.layer34_metadata.ip_dst = 0;
        meta.layer34_metadata.ip_ver = 0;
        meta.layer34_metadata.l4_src = 0;
        meta.layer34_metadata.l4_dst = 0;
        meta.layer34_metadata.l4_proto = 0;
        meta.layer34_metadata.l3_mtu = 0;
        meta.layer34_metadata.dscp = 0;
        meta.int_len_bytes = 0;

        mirror_h mirror_md= pkt.lookahead<mirror_h>();
        transition select(mirror_md.mirror_type) {
            0: parse_bridge;
            1: parse_mirror;
        default: accept;
        }
    }

    state parse_bridge{
        pkt.extract(meta.int_metadata);
        transition parse_ethernet;
    }

    state parse_mirror{
        pkt.extract(meta.mirror_md);
        meta.int_metadata.ingress_tstamp = meta.mirror_md.ingress_tstamp;
        meta.int_metadata.ingress_port = meta.mirror_md.ingress_port;
        transition parse_ethernet;
    }

    state parse_ethernet {
        pkt.extract(hdr.ethernet);
        transition select(hdr.ethernet.etherType) {
            16w0x800: parse_ipv4;
            default: accept;
        }
    }

    state parse_ipv4 {
        pkt.extract(hdr.ipv4);
        meta.layer34_metadata.ip_src = hdr.ipv4.srcAddr;
        meta.layer34_metadata.ip_dst = hdr.ipv4.dstAddr;
        meta.layer34_metadata.ip_ver = 8w4;
        meta.layer34_metadata.dscp = hdr.ipv4.dscp;

        ipv4_checksum.add(hdr.ipv4);
        /*// Output of verify is 0 or 1*/
        /*// If it is 1, there is checksum error*/
        ipv4_checksum.verify();

        transition select(hdr.ipv4.protocol) {
            8w0x11: parse_udp;
            8w0x6: parse_tcp;
            default: reject; /*Debug
            default: accept; */
        }
    }

    state parse_tcp {
        pkt.extract(hdr.tcp);
        meta.layer34_metadata.l4_src = hdr.tcp.srcPort;
        meta.layer34_metadata.l4_dst = hdr.tcp.dstPort;
        meta.layer34_metadata.l4_proto = 8w0x6;
        transition select(meta.layer34_metadata.dscp) {
            IPv4_DSCP_INT: parse_int;
            default: accept;
        }
    }

    state parse_udp {
        pkt.extract(hdr.udp);
        meta.layer34_metadata.l4_src = hdr.udp.srcPort;
        meta.layer34_metadata.l4_dst = hdr.udp.dstPort;
        meta.layer34_metadata.l4_proto = 8w0x11;
        transition select(meta.layer34_metadata.dscp, hdr.udp.dstPort) {
            (6w0x20 &&& 6w0x3f, 16w0x0 &&& 16w0x0): parse_int;
            default: accept;
        }
    }

    state parse_int {
        pkt.extract(hdr.int_shim);
        pkt.extract(hdr.int_header);
        // DAMU: warning (from TOFINO): Parser "verify" is currently unsupported
        /*verify(hdr.int_header.ver == INT_VERSION, error.INTVersionNotSupported);*/

        transition select(hdr.int_shim.len) {
            (8w0x03): accept; //shim and int headers only, after ingress source activation
            (8w0x04): parse_int_data_32;
            (8w0x05): parse_int_data_64;
            (8w0x06): parse_int_data_96;
            (8w0x07): parse_int_data_128;
            (8w0x08): parse_int_data_160;
            (8w0x09): parse_int_data_192;
            (8w0x0a): parse_int_data_224;
            (8w0x0b): parse_int_data_256;
            (8w0x0c): parse_int_data_288;
            (8w0x0d): parse_int_data_320;
            (8w0x0f): parse_int_data_384;
            (8w0x11): parse_int_data_448;
            (8w0x12): parse_int_data_480;
            (8w0x13): parse_int_data_512;
            (8w0x15): parse_int_data_576;
            (8w0x17): parse_int_data_640;
            (8w0x18): parse_int_data_672;
            (8w0x1b): parse_int_data_768;
            (8w0x1e): parse_int_data_864;
            (8w0x1f): parse_int_data_896;
            (8w0x21): parse_int_data_960;
            (8w0x23): parse_int_data_1024;
            (8w0x27): parse_int_data_1152;
            (8w0x2b): parse_int_data_1280;
        }
    }
    // Automatically generated data parsing states
    state parse_int_data_32 {
        pkt.extract(hdr.int_data, 32);
        meta.int_len_bytes = 16;
        transition accept;
    }

    state parse_int_data_64 {
        pkt.extract(hdr.int_data, 64);
        meta.int_len_bytes = 20;
        transition accept;
    }

    state parse_int_data_96 {
        pkt.extract(hdr.int_data, 96);
        meta.int_len_bytes = 24;
        transition accept;
    }

    state parse_int_data_128 {
        pkt.extract(hdr.int_data, 128);
        meta.int_len_bytes = 28;
        transition accept;
    }

    state parse_int_data_160 {
        pkt.extract(hdr.int_data, 160);
        meta.int_len_bytes = 32;
        transition accept;
    }

    state parse_int_data_192 {
        pkt.extract(hdr.int_data, 192);
        meta.int_len_bytes = 36;
        transition accept;
    }

    state parse_int_data_224 {
        pkt.extract(hdr.int_data, 224);
        meta.int_len_bytes = 40;
        transition accept;
    }

    state parse_int_data_256 {
        pkt.extract(hdr.int_data, 256);
        meta.int_len_bytes = 44;
        transition accept;
    }

    state parse_int_data_288 {
        pkt.extract(hdr.int_data, 288);
        meta.int_len_bytes = 48;
        transition accept;
    }

    state parse_int_data_320 {
        pkt.extract(hdr.int_data, 320);
        meta.int_len_bytes = 52;
        transition accept;
    }

    state parse_int_data_384 {
        pkt.extract(hdr.int_data, 384);
        meta.int_len_bytes = 60;
        transition accept;
    }

    state parse_int_data_448 {
        pkt.extract(hdr.int_data, 448);
        meta.int_len_bytes = 68;
        transition accept;
    }

    state parse_int_data_480 {
        pkt.extract(hdr.int_data, 480);
        meta.int_len_bytes = 72;
        transition accept;
    }

    state parse_int_data_512 {
        pkt.extract(hdr.int_data, 512);
        meta.int_len_bytes = 76;
        transition accept;
    }

    state parse_int_data_576 {
        pkt.extract(hdr.int_data, 576);
        meta.int_len_bytes = 84;
        transition accept;
    }

    state parse_int_data_640 {
        pkt.extract(hdr.int_data, 640);
        meta.int_len_bytes = 92;
        transition accept;
    }

    state parse_int_data_672 {
        pkt.extract(hdr.int_data, 672);
        meta.int_len_bytes = 96;
        transition accept;
    }

    state parse_int_data_768 {
        pkt.extract(hdr.int_data, 768);
        meta.int_len_bytes = 108;
        transition accept;
    }

    state parse_int_data_864 {
        pkt.extract(hdr.int_data, 864);
        meta.int_len_bytes = 120;
        transition accept;
    }

    state parse_int_data_896 {
        pkt.extract(hdr.int_data, 896);
        meta.int_len_bytes = 124;
        transition accept;
    }

    state parse_int_data_960 {
        pkt.extract(hdr.int_data, 960);
        meta.int_len_bytes = 132;
        transition accept;
    }

    state parse_int_data_1024 {
        pkt.extract(hdr.int_data, 1024);
        meta.int_len_bytes = 140;
        transition accept;
    }

    state parse_int_data_1152 {
        pkt.extract(hdr.int_data, 1152);
        meta.int_len_bytes = 156;
        transition accept;
    }

    state parse_int_data_1280 {
        pkt.extract(hdr.int_data, 1280);
        meta.int_len_bytes = 172;
        transition accept;
    }
}
/*********************  I N G R E S S   D E P A R S E R  ************************/

control IngressDeparser(packet_out packet,
    inout headers hdr,
    in metadata meta,
    in ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md) {

    Checksum() ipv4_csum;
    Mirror() mirror;
    apply {
        // Updating and checking of the checksum is done in the deparser.
        // Checksumming units are only available in the parser sections of
        // the program
        if(hdr.ipv4.isValid()){
            hdr.ipv4.hdrChecksum = ipv4_csum.update(
                {
                    hdr.ipv4.version,
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
                    hdr.ipv4.dstAddr
                }
            );
        }

        // Send the mirror of hdr to collector
        if (meta.mirror_md.mirror_type == 1) {
            mirror.emit<mirror_h>(meta.int_metadata.session_ID, {meta.mirror_md.mirror_type, meta.int_metadata.ingress_tstamp, meta.int_metadata.ingress_port});
        }
        // bridge header
        packet.emit(meta.int_metadata);
        
        // original headers
        packet.emit(hdr.ethernet);
        packet.emit(hdr.ipv4);
        packet.emit(hdr.udp);
        packet.emit(hdr.tcp);
        
        // INT headers
        packet.emit(hdr.int_shim);
        packet.emit(hdr.int_header);

        /* Fede: these will never be valid in the Ingress pipeline
        // local INT node metadata
        packet.emit(hdr.int_switch_id);
        packet.emit(hdr.int_port_ids);
        packet.emit(hdr.int_hop_latency);
        packet.emit(hdr.int_q_occupancy);
        packet.emit(hdr.int_ingress_tstamp);
        packet.emit(hdr.int_egress_tstamp);
        packet.emit(hdr.int_level2_port_ids);
        packet.emit(hdr.int_egress_port_tx_util);
        */

    }
}


/*********************  E G R E S S    D E P A R S E R  ************************/

control EgressDeparser(packet_out packet,
                                    /* User */
                                    inout headers                       hdr,
                                    in    metadata                      meta,
                                    /* Intrinsic */
                                    in    egress_intrinsic_metadata_for_deparser_t  eg_dprsr_md) {
    
    Checksum() ipv4_csum;
    apply {
        // Updating and checking of the checksum is done in the deparser.
        // Checksumming units are only available in the parser sections of
        // the program
	if(hdr.report_ipv4.isValid()){
	   hdr.report_ipv4.hdrChecksum = ipv4_csum.update(
                {
                    hdr.report_ipv4.version,
                    hdr.report_ipv4.ihl,
                    hdr.report_ipv4.dscp,
                    hdr.report_ipv4.ecn,
                    hdr.report_ipv4.totalLen,
                    hdr.report_ipv4.id,
                    hdr.report_ipv4.flags,
                    hdr.report_ipv4.fragOffset,
                    hdr.report_ipv4.ttl,
                    hdr.report_ipv4.protocol,
                    hdr.report_ipv4.srcAddr,
                    hdr.report_ipv4.dstAddr
                }
            );

	}
        if(hdr.ipv4.isValid()){
            hdr.ipv4.hdrChecksum = ipv4_csum.update(
                {
                    hdr.ipv4.version,
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
                    hdr.ipv4.dstAddr
                }
            );
        }
        
        // report headers
        packet.emit(hdr.report_ethernet);
        packet.emit(hdr.report_ipv4);
        packet.emit(hdr.report_udp);
        packet.emit(hdr.report_fixed_header);

        // original headers
        packet.emit(hdr.ethernet);
        packet.emit(hdr.ipv4);
        packet.emit(hdr.udp);
        packet.emit(hdr.tcp);
        
        // INT headers
        packet.emit(hdr.int_shim);
        packet.emit(hdr.int_header);
        
        // local INT node data
        packet.emit(hdr.int_switch_id);
        packet.emit(hdr.int_port_ids);
        packet.emit(hdr.int_hop_latency);
        packet.emit(hdr.int_q_occupancy);
        packet.emit(hdr.int_ingress_tstamp);
        packet.emit(hdr.int_egress_tstamp);
        packet.emit(hdr.int_level2_port_ids);
        packet.emit(hdr.int_egress_port_tx_util);

        // Previous nodes INT data
        packet.emit(hdr.int_data);
	}
    }
#endif


