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
 
#ifndef _HEADERS_P4_
#define _HEADERS_P4_

const bit<16> TYPE_IPV4 = 0x0800;
const bit<16> TYPE_ARP = 0x0806;

header ethernet_t {
    bit<48> dstAddr;
    bit<48> srcAddr;
    bit<16> etherType;
}

const bit<16> ARP_HTYPE_ETHERNET = 0x0001;
const bit<16> ARP_PTYPE_IPV4     = 0x0800;
const bit<8>  ARP_HLEN_ETHERNET  = 6;
const bit<8>  ARP_PLEN_IPV4      = 4;
const bit<16> ARP_OPER_REQUEST   = 1;
const bit<16> ARP_OPER_REPLY     = 2;

header arp_t {
    bit<16>   htype;
    bit<16>   ptype;
    bit<8>    hlen;
    bit<8>    plen;
    bit<16>  opcode;
    bit<48> srcMAC;
    bit<32> srcIP;
    bit<48> dstMAC;
    bit<32> dstIP;
}
/*
header ipv4_t {
    bit<4>  version;
    bit<4>  ihl;
    bit<6>  dscp;
    bit<2>  ecn;
    bit<16> totalLen;
    bit<16> id;
    bit<3>  flags;
    bit<13> fragOffset;
    bit<8>  ttl;
    bit<8>  protocol;
    bit<16> hdrChecksum;
    bit<32> srcAddr;
    bit<32> dstAddr;
}
*/

header ipv4_t {
    bit<4>  version;
    bit<4>  ihl;
    bit<8>  diffserv;
    bit<16> totalLen;
    bit<16> identification;
    bit<3>  flags;
    bit<13> fragOffset;
    bit<8>  ttl;
    bit<8>  protocol;
    bit<16> hdrChecksum;
    bit<32> srcAddr;
    bit<32> dstAddr;
}

header udp_t {
    bit<16> srcPort;
    bit<16> dstPort;
    bit<16> len;
    bit<16> csum;
}

/*
header tcp_t {
    bit<16> srcPort;
    bit<16> dstPort;
    bit<32> seqNum;
    bit<32> ackNum;
    bit<4>  dataOffset;
    bit<3>  reserved;
    bit<9>  flags;
    bit<16> winSize;
    bit<16> csum;
    bit<16> urgPoint;
} */

header tcp_t {
    bit<16> srcPort;
    bit<16> dstPort;
    bit<32> seqNo;
    bit<32> ackNo;
    bit<4>  dataOffset;
    bit<4>  res;
    bit<8>  flags;
    bit<16> window;
    bit<16> checksum;
    bit<16> urgentPtr;
}

header twamp_test_t {
    bit<32> sequenceNumber;
    bit<64> timestamp;
    bit<16> errorEstimate;
    bit<16> mbz0;
    bit<64> receiveTimestamp;
    bit<32> senderSequenceNumber;
    bit<64> senderTimestamp;
    bit<16> senderErrorEstimate;
    bit<16> mbz1;
    bit<8> senderTTL;
    //padding
}

struct headers {
    ethernet_t              ethernet;
    arp_t                      arp;
    ipv4_t                    ipv4;
    tcp_t                      tcp;
    udp_t                     udp;
    twamp_test_t         twamp_test;
}


header checksum_metadata_t {
    bit<16> L4Length;
}

header loopback_metadata_t {
    bit<32> cpu_ip;       // IP address of CPU veth endpoint
    bit<48> cpu_mac;    // MAC address of CPU veth endpoint
    bit<9> cpu_port;      // port id of bmv2 veth endpoint
    bit<48> dp_mac;     // MAC address of bmv2 veth endpoint
}

struct metadata {
    checksum_metadata_t checksum;
    loopback_metadata_t loopback;
}

#endif
