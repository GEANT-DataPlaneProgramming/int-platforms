/*
 * Copyright 2020-present PSNC
 *
 * Created in the EU GN4-3 project
 *
 * Author: Damian Parniewicz
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


parser ParserImpl(packet_in packet, out headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {

    state parse_twamp_test {
        packet.extract(hdr.twamp_test);
        transition accept;
    }
    state parse_tcp {
        packet.extract(hdr.tcp);
        transition accept;
    }
    state parse_udp {
        packet.extract(hdr.udp);
        transition select(hdr.udp.dstPort) {
            8975: parse_twamp_test;
            default: accept;
        }
    }
    state parse_ipv4 {
        packet.extract(hdr.ipv4);
        meta.checksum.L4Length = hdr.ipv4.totalLen - 16w20;
        transition select(hdr.ipv4.protocol) {
            8w0x11: parse_udp;
            8w0x6: parse_tcp;
            default: accept;
        }
    }
    state parse_arp {
        packet.extract(hdr.arp);
        transition accept;
    }
    state parse_ethernet {
        packet.extract(hdr.ethernet);
        transition select(hdr.ethernet.etherType) {
            TYPE_IPV4: parse_ipv4;
            TYPE_ARP: parse_arp;
            default: accept;
        }
    }
    state start {
        transition select((packet.lookahead<bit<64>>())[63:0]) {
            default: parse_ethernet;
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
        packet.emit(hdr.arp);
        packet.emit(hdr.ipv4);
        packet.emit(hdr.udp);
        packet.emit(hdr.tcp);
        packet.emit(hdr.twamp_test);
    }
}

control verifyChecksum(inout headers hdr, inout metadata meta) {
    apply {
        verify_checksum(
            true, 
            { hdr.ipv4.version, 
                hdr.ipv4.ihl, 
                hdr.ipv4.diffserv, 
                hdr.ipv4.totalLen, 
                hdr.ipv4.identification, 
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
        /*    
        verify_checksum_with_payload(
            hdr.tcp.isValid(), 
            {  hdr.ipv4.srcAddr, 
                hdr.ipv4.dstAddr, 
                8w0, 
                hdr.ipv4.protocol, 
                meta.checksum.L4Length, 
                hdr.tcp.srcPort, 
                hdr.tcp.dstPort, 
                hdr.tcp.seqNo, 
                hdr.tcp.ackNo, 
                hdr.tcp.dataOffset, 
                hdr.tcp.res, 
                hdr.tcp.flags, 
                hdr.tcp.window, 
                hdr.tcp.urgentPtr 
            }, 
            hdr.tcp.checksum, 
            HashAlgorithm.csum16
        );
        */
    }
}

control computeChecksum(inout headers hdr, inout metadata meta) {
    apply {
        update_checksum(
            hdr.ipv4.isValid(), 
            {  hdr.ipv4.version, 
                hdr.ipv4.ihl, 
                hdr.ipv4.diffserv, 
                hdr.ipv4.totalLen, 
                hdr.ipv4.identification, 
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
            hdr.udp.isValid() && hdr.twamp_test.isValid() , 
            {  hdr.ipv4.srcAddr, 
                hdr.ipv4.dstAddr, 
                8w0, 
                hdr.ipv4.protocol, 
                hdr.udp.len, 
                hdr.udp.srcPort, 
                hdr.udp.dstPort, 
                hdr.udp.len,
                hdr.twamp_test.sequenceNumber,
                hdr.twamp_test.timestamp,
                hdr.twamp_test.errorEstimate,
                hdr.twamp_test.mbz0,
                hdr.twamp_test.receiveTimestamp,
                hdr.twamp_test.senderSequenceNumber,
                hdr.twamp_test.senderTimestamp,
                hdr.twamp_test.senderErrorEstimate,
                hdr.twamp_test.mbz1,
                hdr.twamp_test.senderTTL
            }, 
            hdr.udp.csum, 
            HashAlgorithm.csum16
        );
        
        /*
        update_checksum_with_payload(
            hdr.tcp.isValid(), 
            {  hdr.ipv4.srcAddr, 
                hdr.ipv4.dstAddr, 
                8w0, 
                hdr.ipv4.protocol, 
                meta.checksum.L4Length, 
                hdr.tcp.srcPort, 
                hdr.tcp.dstPort, 
                hdr.tcp.seqNo, 
                hdr.tcp.ackNo, 
                hdr.tcp.dataOffset, 
                hdr.tcp.res, 
                hdr.tcp.flags, 
                hdr.tcp.window, 
                hdr.tcp.urgentPtr 
            }, 
            hdr.tcp.checksum, 
            HashAlgorithm.csum16
        );
        */
    }
    
}
