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

const bit<9> CPU_PORT = 3;

const bit<32> IP_HASH_SIZE = 1024;
register<bit<9>> (IP_HASH_SIZE) ip_to_port_hash;
register<bit<48>> (IP_HASH_SIZE) ip_to_mac_hash;

const bit<48> CPU_MAC = 0xf661c06a1466;
const bit<32> CPU_IP = 0x0a0000fe;
const bit<48> DP_MAC =  0xf661c06a0077;
const bit<32> TWAMP_REFLECTOR_IP = 0x0a0000fd;
const bit<48> TWAMP_REFLECTOR_MAC =  0xf661c06a0055;
const bit<48> BROADCAST_MAC = 0xFFFFFFFFFFFF;


control Loopback(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {

    action send_frame_to_cpu(bit<9> port, bit<48> dp_mac) {
        // decided not to use CPU header in order to enable default linux networking stack behaviour 
        // for a packet within CPU host (e.g.: TCP handshake procedure).
        
        // CPU header stores a local port id from where packet was received in order to know where send a frame response
        //hdr.cpu_header.setValid();
        //hdr.cpu_header.preamble = 64w0;
        //hdr.cpu_header.device = 8w0;
        //hdr.cpu_header.reason = 8w0xab;
        //hdr.cpu_header.port = (bit<8>)standard_metadata.ingress_port;
        
        standard_metadata.egress_spec = port;
        
        //store a local port id and remote mac address where a remote IP address was seen
        bit<32> hash_index_w;
        hash(hash_index_w, HashAlgorithm.crc32, 32w0, {hdr.ipv4.srcAddr}, IP_HASH_SIZE);
        ip_to_port_hash.write(hash_index_w, standard_metadata.ingress_port);
        ip_to_mac_hash.write(hash_index_w, hdr.ethernet.srcAddr);
        
        hdr.ethernet.srcAddr = dp_mac;
        exit;
    }

    table tb_configure_loopback_in {
        actions = {
            send_frame_to_cpu;
        }
        key = {
            hdr.ethernet.dstAddr     : ternary;
        }
        size = 16;
        const entries = {
            CPU_MAC : send_frame_to_cpu(CPU_PORT, DP_MAC);
            //BROADCAST_MAC : send_frame_to_cpu(CPU_PORT, DP_MAC);
        }
    }

    
    //action decap_cpu_header() {
    //    standard_metadata.egress_spec = (bit<9>)hdr.cpu_header.port;
    //    hdr.cpu_header.setInvalid();
    //}
    
    action send_frame_from_cpu() {
        //lookup for a local port id and remote mac address where a switch can find a remote IPv4 address 
        bit<32> hash_index_r;
        hash(hash_index_r, HashAlgorithm.crc32, 32w0, {hdr.ipv4.dstAddr}, IP_HASH_SIZE);
        ip_to_port_hash.read(standard_metadata.egress_spec, hash_index_r);
        ip_to_mac_hash.read(hdr.ethernet.dstAddr, hash_index_r);
        exit;
    }
    
    table tb_configure_loopback_out {
        actions = {
            send_frame_from_cpu;
        }
        key = {
            standard_metadata.ingress_port     : exact;
        }
        size = 1024;
        const entries = {
            CPU_PORT : send_frame_from_cpu();
        }
    }
    

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

    
    action drop() {
        mark_to_drop();
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
            drop;
        }
        const entries = {
            (true, ARP_OPER_REQUEST,  CPU_IP) : send_arp_reply(CPU_MAC);
            (true, ARP_OPER_REQUEST,  TWAMP_REFLECTOR_IP) : send_arp_reply(TWAMP_REFLECTOR_MAC);
        }
    } 
    
    apply {
        tb_arp_responder.apply();
        
        if (hdr.arp.isValid() && hdr.arp.opcode == ARP_OPER_REQUEST && standard_metadata.ingress_port == CPU_PORT)
             send_arp_reply(DP_MAC);
        
        //if (hdr.cpu_header.isValid()) {
        //    decap_cpu_header();
        //}
        /*
        if (!hdr.arp.isValid()) {
            tb_configure_loopback_out.apply();
            
            if (hdr.ipv4.isValid())      
                tb_configure_loopback_in.apply();
        }
        */
        tb_configure_loopback_in.apply();
        tb_configure_loopback_out.apply();
    }
}
