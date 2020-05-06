/*
 * Copyright 2020-present PSNC
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

control ARP_Responder(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {

    action send_arp_reply(bit<48> my_mac) {
        hdr.ethernet.dstAddr = hdr.arp.srcMAC;
        hdr.ethernet.srcAddr = my_mac;
        
        hdr.arp.opcode         = ARP_OPER_REPLY;
        
        bit<32> ip = hdr.arp.dstIP;
        hdr.arp.dstMAC = hdr.arp.srcMAC;
        hdr.arp.dstIP = hdr.arp.srcIP;
        hdr.arp.srcMAC = my_mac;
        hdr.arp.srcIP = ip;

        standard_metadata.egress_spec = standard_metadata.ingress_port;
        exit;
    }
    
    table tb_arp_responder {
        key = {
            hdr.arp.isValid()      : exact;
            hdr.arp.opcode        : ternary;
            hdr.arp.dstIP           : exact;
        }
        actions = {
            send_arp_reply;
        }
        const entries = {
            (true, ARP_OPER_REQUEST,  CPU_IP) : send_arp_reply(CPU_MAC);
            (true, ARP_OPER_REQUEST,  TWAMP_REFLECTOR_IP) : send_arp_reply(TWAMP_REFLECTOR_MAC);
        }
    } 
    
    apply {
        tb_arp_responder.apply();
        
        if (hdr.arp.isValid() && hdr.arp.opcode == ARP_OPER_REQUEST && standard_metadata.ingress_port == meta.loopback.cpu_port)
             send_arp_reply(meta.loopback.dp_mac);
    }
}