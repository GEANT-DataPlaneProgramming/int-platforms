  /*
 * Copyright 2020 Bartosz Krakowiak
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
 
// Code adapted from:
// - https://github.com/baru64/int-p4/blob/master/int.p4app/p4src/int_report.p4
 
 
// register to store seq_num
register<bit<32>> (1) report_seq_num_register;

#ifdef BMV2

control Int_report(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {

#elif TOFINO

control Int_report(inout headers hdr, inout metadata meta, inout ingress_intrinsic_metadata_for_tm_t standard_metadata) {

#endif

    bit<32> seq_num_value = 0;

    // INT Raport structure
    // [Eth][IP][UDP][INT RAPORT HDR][ETH][IP][UDP/TCP][INT SHIM][INT DATA]
        
    action send_report(bit<48> dp_mac, bit<32> dp_ip, bit<48> collector_mac, bit<32> collector_ip, bit<16> collector_port) {
    
        // Ethernet **********************************************************
        hdr.report_ethernet.setValid();
        hdr.report_ethernet.dstAddr = collector_mac;
        hdr.report_ethernet.srcAddr = dp_mac;
        hdr.report_ethernet.etherType = 0x0800;

        // IPv4 **************************************************************
        hdr.report_ipv4.setValid();
        hdr.report_ipv4.version = 4;
        hdr.report_ipv4.ihl = 5;
        hdr.report_ipv4.dscp = 0;
        hdr.report_ipv4.ecn = 0;
        // 2x ipv4 header + udp header + eth header + report header + int data len
        hdr.report_ipv4.totalLen = (bit<16>)(20 + 20 + 8 + 14)
                                    + (bit<16>)REPORT_FIXED_HEADER_LEN
                                    + (((bit<16>)hdr.int_shim.len) << 2 );
        // add size of original tcp/udp header
        if (hdr.tcp.isValid()) {
            hdr.report_ipv4.totalLen = hdr.report_ipv4.totalLen
                                       + (((bit<16>)hdr.tcp.dataOffset) << 2);
        } else {
            hdr.report_ipv4.totalLen = hdr.report_ipv4.totalLen + 8;
        }
        hdr.report_ipv4.id = 0;
        hdr.report_ipv4.flags = 0;
        hdr.report_ipv4.fragOffset = 0;
        hdr.report_ipv4.ttl = 64;
        hdr.report_ipv4.protocol = 17; // UDP
        hdr.report_ipv4.srcAddr = dp_ip;
        hdr.report_ipv4.dstAddr = collector_ip;

        // UDP ***************************************************************
        hdr.report_udp.setValid();
        hdr.report_udp.srcPort = 2048;
        hdr.report_udp.dstPort = collector_port;
        // ipv4 header + 2x udp header + eth header + report header + int data len
        // hdr.report_udp.len = (bit<16>)(20 + 8 + 8 + 14)
        //                       + (bit<16>)REPORT_FIXED_HEADER_LEN
        //                       + (((bit<16>)hdr.int_shim.len) << 2 );
        hdr.report_udp.len = hdr.report_ipv4.totalLen - 20;
        
        // INT report fixed header ***********************************************
        hdr.report_fixed_header.setValid();
        hdr.report_fixed_header.ver = 1;
        hdr.report_fixed_header.len = 4;
        hdr.report_fixed_header.nprot = 0; // 0 for Ethernet
        hdr.report_fixed_header.rep_md_bits = 0;
        hdr.report_fixed_header.reserved = 0;
        hdr.report_fixed_header.d = 0;
        hdr.report_fixed_header.q = 0;
        // f - indicates that report is for tracked flow, INT data is present
        hdr.report_fixed_header.f = 1;
        // hw_id - specific to the switch, e.g. id of linecard
        hdr.report_fixed_header.hw_id = 0;
        hdr.report_fixed_header.switch_id = meta.int_metadata.switch_id;
        report_seq_num_register.read(seq_num_value, 0);
        hdr.report_fixed_header.seq_num = seq_num_value;
        report_seq_num_register.write(0, seq_num_value + 1);
        hdr.report_fixed_header.ingress_tstamp = (bit<32>)standard_metadata.ingress_global_timestamp;
        
        // Original packet headers, INT shim and INT data come after report header.
        // drop all data besides int report and report eth header
        truncate((bit<32>)hdr.report_ipv4.totalLen + 14);
    }

    table tb_int_reporting {
        actions = {
            send_report;
        }
    }

    apply {
        tb_int_reporting.apply();
    }
}