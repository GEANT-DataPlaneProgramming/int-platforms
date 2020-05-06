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

const bit<9> CPU_PORT = 2;

const bit<32> IP_HASH_SIZE = 1024;
register<bit<9>> (IP_HASH_SIZE) ip_to_port_hash;
register<bit<48>> (IP_HASH_SIZE) ip_to_mac_hash;

const bit<48> CPU_MAC = 0xf661c06a1466;
const bit<32> CPU_IP = 0x0a0000fe;
const bit<48> DP_MAC =  0xf661c06a0077;
const bit<48> TWAMP_REFLECTOR_MAC =  0xf661c06a0055;
const bit<48> BROADCAST_MAC = 0xFFFFFFFFFFFF;


control CPU_Loopback(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {

    action configure_loopback(bit<32> cpu_ip, bit<48> cpu_mac, bit<9> cpu_port, bit<48> dp_mac) {
        meta.loopback.cpu_ip = cpu_ip;
        meta.loopback.cpu_mac = cpu_mac;
        meta.loopback.cpu_port = cpu_port;
        meta.loopback.dp_mac = dp_mac;
    }
    
    table tb_configure_loopback {
        actions = {
            configure_loopback;
        }
        const default_action = configure_loopback(CPU_IP, CPU_MAC, CPU_PORT, DP_MAC);
    }
    
    action send_frame_to_cpu() {
        //store a local port id and remote mac address where a remote IP address was seen
        bit<32> hash_index_w;
        hash(hash_index_w, HashAlgorithm.crc32, 32w0, {hdr.ipv4.srcAddr}, IP_HASH_SIZE);
        ip_to_port_hash.write(hash_index_w, standard_metadata.ingress_port);
        ip_to_mac_hash.write(hash_index_w, hdr.ethernet.srcAddr);
        
        hdr.ethernet.srcAddr = meta.loopback.dp_mac;
        standard_metadata.egress_spec = meta.loopback.cpu_port;
        exit;
    }
    
    action send_frame_from_cpu() {
        //lookup for a local port id and remote mac address where a switch can find a remote IPv4 address 
        bit<32> hash_index_r;
        hash(hash_index_r, HashAlgorithm.crc32, 32w0, {hdr.ipv4.dstAddr}, IP_HASH_SIZE);
        ip_to_port_hash.read(standard_metadata.egress_spec, hash_index_r);
        ip_to_mac_hash.read(hdr.ethernet.dstAddr, hash_index_r);
        exit;
    }
    
    apply {
        tb_configure_loopback.apply();
        if (hdr.ethernet.dstAddr == meta.loopback.cpu_mac)
            send_frame_to_cpu();
        if (standard_metadata.ingress_port == meta.loopback.cpu_port && hdr.ipv4.isValid())
            send_frame_from_cpu();
    }
}
