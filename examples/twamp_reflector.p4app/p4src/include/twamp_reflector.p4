/*
 * Copyright 2020 PSNC
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
 

control TwampReflector(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {

    action configure_reflector(bit<32> senderAddr, bit<16> senderPort, bit<32> receiverAddr, bit<16> receiverPort,  bit<32> dscp) {
        meta.twamp.senderAddr = senderAddr;
        meta.twamp.senderPort = senderPort;
        meta.twamp.receiverAddr = receiverAddr;
        meta.twamp.receiverPort = receiverPort;
        meta.twamp.dscp = dscp;
    }
    table tb_configure_reflector {
        actions = {
            configure_reflector;
        }
    }
    
    action bmv2timestamp_to_ntp(in bit<48> timestamp, out bit<64> ntp) {
        // converts bmv2 timestamp (number of miliseconds from bmv2 start to NTP timestamp
        // TODO: configure number of seconds from 1900 to bmv2 start
        bit<32> seconds = (bit<32>) (timestamp >> 10);  //simplication (divide by 1024 instead of 1000)
        bit<32> miliseconds = (bit<32>) (timestamp & 0x400); //simplication (modulo by 1024 instead of 1000)
        ntp = (bit<64>)seconds<<32;
        ntp = ntp + (bit<64>)0;  // TODO: convert miliseconds to fraction of a second (a float value)
    }
    
    action twamp_reflect() {
    
        bit<48> dst = hdr.ethernet.dstAddr;
        hdr.ethernet.dstAddr = hdr.ethernet.srcAddr;
        hdr.ethernet.srcAddr = dst;

        bit<32> dstIP = hdr.ipv4.dstAddr;
        hdr.ipv4.dstAddr = hdr.ipv4.srcAddr;
        hdr.ipv4.srcAddr = dstIP;
        
        bit<16> dstPort = hdr.udp.dstPort;
        hdr.udp.dstPort = hdr.udp.srcPort;
        hdr.udp.srcPort = dstPort;
        
        hdr.twamp_test.senderSequenceNumber = hdr.twamp_test.sequenceNumber;
        hdr.twamp_test.senderTimestamp = hdr.twamp_test.timestamp;
        hdr.twamp_test.senderErrorEstimate = hdr.twamp_test.errorEstimate;
        hdr.twamp_test.senderTTL = hdr.ipv4.ttl;
        
        bmv2timestamp_to_ntp(standard_metadata.ingress_global_timestamp, hdr.twamp_test.receiveTimestamp);
        bmv2timestamp_to_ntp(standard_metadata.egress_global_timestamp, hdr.twamp_test.timestamp);
        //hdr.twamp_test.errorEstimate = ?; //TODO: use local time error estimate
        
        // send frame back to TWAMP client
        standard_metadata.egress_spec = standard_metadata.ingress_port;
        exit;
    }
    apply {
        tb_configure_reflector.apply();
        
        if (hdr.twamp_test.isValid())
            twamp_reflect();
    }
}
