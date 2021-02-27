/*
 * Copyright 2017-present Open Networking Foundation
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
 
control Gtp_tunnel(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {

    action add_gtp() {
        hdr.gtp.setValid();
        hdr.gtp.version = 3w1;
        hdr.gtp.protType = 1w0;
        hdr.gtp.reserved = 1w0;
        hdr.gtp.flags = 3w0;
        hdr.gtp.messageType = 8w0;
        hdr.gtp.messageLen = 16w0;
        hdr.gtp.teid = 32w0;
    }
    action add_gtp_add_ipv4() {
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
    action add_gtp_set_new_outer(bit<32> srcAddr, bit<32> dstAddr) {
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
    action add_gtp_to_tcp(bit<32> srcAddr, bit<32> dstAddr) {
        add_gtp();
        add_gtp_add_ipv4();
        hdr.udp.len = 16w0;
        add_gtp_set_new_outer(srcAddr, dstAddr);
        hdr.udp.len = hdr.udp.len + hdr.enc_ipv4.totalLen;
        hdr.udp.len = hdr.udp.len - 16w20;
    }
    action add_gtp_to_udp(bit<32> srcAddr, bit<32> dstAddr) {
        add_gtp();
        add_gtp_add_ipv4();
        hdr.enc_udp.setValid();
        hdr.enc_udp.srcPort = hdr.udp.srcPort;
        hdr.enc_udp.dstPort = hdr.udp.dstPort;
        hdr.enc_udp.len = hdr.udp.len;
        hdr.enc_udp.csum = hdr.udp.csum;
        add_gtp_set_new_outer(srcAddr, dstAddr);
    }

    table tab_add_gtp_to_tcp {
        actions = {
            add_gtp_to_tcp;
        }
    }
    table tab_add_gtp_to_udp {
        actions = {
            add_gtp_to_udp;
        }
    }

    apply {
        if (hdr.gtp.isValid()) {
            if (hdr.udp.isValid()) 
                  tab_add_gtp_to_udp.apply();

            if (hdr.tcp.isValid())
                tab_add_gtp_to_tcp.apply();
        }
    }
}