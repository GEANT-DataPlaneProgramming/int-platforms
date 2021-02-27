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
 

const bit<32> TWAMP_REFLECTOR_IP = 0x0a0000fe;
const bit<32> TWAMP_REFLECTOR_IP_2 = 0x0a0000fd;
const bit<32> CLIENT_IP = 0x0a000101;
const bit<16> TWAMP_REFLECTOR_PORT = 8975;
const bit<16> CLIENT_PORT = 20001;

// seconds from 1900 to start time of bmv2 instance
register<bit<32>> (1) start_timestamp;

control TwampReflector(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    
    action bmv2timestamp_to_ntp(in bit<48> timestamp, out bit<64> ntp) {
        // converts bmv2 timestamp (number of miliseconds from bmv2 start to NTP timestamp
        // TODO: configure number of seconds from 1900 to bmv2 start
        bit<32> seconds = 0;  
        start_timestamp.read(seconds, 0);
        seconds = seconds + (bit<32>) (timestamp >> 20); //simplication (divide by 1048576 instead of a million)
        bit<32> miliseconds = (bit<32>) (timestamp & 0xFFFFF); //simplication (modulo by 1048576 instead of a million)
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
        bmv2timestamp_to_ntp(standard_metadata.ingress_global_timestamp, hdr.twamp_test.timestamp);
        
        //hdr.twamp_test.errorEstimate = ?; //TODO: currently using client errorEstimate (not overwritting by the reflector)
        
        // send frame back to TWAMP client
        standard_metadata.egress_spec = standard_metadata.ingress_port;
        exit;
    }
    
    table tb_twamp_reflector {
        key = {
            hdr.twamp_test.isValid()  : exact;
            hdr.ipv4.srcAddr              : exact;
            hdr.udp.srcPort                : exact;
            hdr.ipv4.dstAddr              : exact;
            hdr.udp.dstPort                : exact;
        }
        actions = {
            twamp_reflect;
        }
        const entries = {
            (true, CLIENT_IP,  CLIENT_PORT, TWAMP_REFLECTOR_IP, TWAMP_REFLECTOR_PORT) : twamp_reflect();
            (true, CLIENT_IP,  CLIENT_PORT, TWAMP_REFLECTOR_IP_2, TWAMP_REFLECTOR_PORT) : twamp_reflect();
        }
    }
    
    apply {
        tb_twamp_reflector.apply();
    }
}
