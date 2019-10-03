/*
 * np4_int.cpp: Source of simple INT processing example.
 * Copyright (C) 2018 Netcope Technologies, a.s.
 * Author(s): Tomas Zavodnik <zavodnik@netcope.com>
 * Description:
 * --------------------------------------------------------------------------------
 * ------------------- Netcope P4 INT processing example --------------------------
 * --------------------------------------------------------------------------------
 * - This example application implements simple processing of INT, including      -
 *   detection, extraction and capture of INT headers, and sending Telemetry      -
 *   reports.                                                                     -
 * --------------------------------------------------------------------------------
 * Usage: np4_int [-hvo] [-d card] -r queue -t ip [-p port]
 *   -d card  Card to use (default: 0)
 *   -r queue RX queue to use for metadata
 *   -t ip    Target IPv4 address for Telemetry reports
 *   -p port  Target UDP port for Telemetry reports (default: 32766)
 *   -o       Keep original packets, don't remove INT on output
 *   -h       Writes out help
 *   -v       Verbose mode
 * --------------------------------------------------------------------------------
 */

 /*
 * This file is part of Netcope distribution (https://github.com/netcope).
 * Copyright (c) 2018 Netcope Technologies, a.s.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

#include <iostream>
#include <cstring>
#include <bitset>
#include <arpa/inet.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netinet/ip.h>
#include <netinet/udp.h>
#include <netinet/tcp.h>

// Netcope P4 library
#include <libnp4.h>

#include "arguments.hpp"

/**
 * \brief Netcope P4 INT header
 */
typedef struct __attribute__((__packed__)) np4_int_header {
    uint32_t                source_ip[4];

    uint32_t                destination_ip[4];

    uint16_t                source_port;
    uint16_t                destination_port;

    uint8_t                 ip_ver;
    uint8_t                 l4_proto;
    uint16_t                reserved16_3;

    uint8_t                 int_length;
    uint8_t                 int_inscnt   : 5;
    uint8_t                 int_vld      : 1;
    uint8_t                 reserved2_4  : 2;
    uint16_t                int_insmap;


    uint8_t                 int_hop0_vld : 1;
    uint8_t                 int_hop1_vld : 1;
    uint8_t                 int_hop2_vld : 1;
    uint8_t                 int_hop3_vld : 1;
    uint8_t                 int_hop4_vld : 1;
    uint8_t                 int_hop5_vld : 1;
    uint8_t                 reserved2_5  : 2;
    uint8_t                 reserved8_5;
    uint16_t                reserved16_5;

    uint32_t                int_hop0_swid;
    uint16_t                int_hop0_ingressport;
    uint16_t                int_hop0_egressport;
    uint32_t                int_hop0_hoplatency;
    uint32_t                int_hop0_occupancy_queueid   : 8;
    uint32_t                int_hop0_occupancy_occupancy : 24;
    uint32_t                int_hop0_ingresstimestamp;
    uint32_t                int_hop0_egresstimestamp;
    uint32_t                int_hop0_congestion_queueid    : 8;
    uint32_t                int_hop0_congestion_congestion : 24;
    uint32_t                int_hop0_egressporttxutilization;

    uint32_t                int_hop1_swid;
    uint16_t                int_hop1_ingressport;
    uint16_t                int_hop1_egressport;
    uint32_t                int_hop1_hoplatency;
    uint32_t                int_hop1_occupancy_queueid   : 8;
    uint32_t                int_hop1_occupancy_occupancy : 24;
    uint32_t                int_hop1_ingresstimestamp;
    uint32_t                int_hop1_egresstimestamp;
    uint32_t                int_hop1_congestion_queueid    : 8;
    uint32_t                int_hop1_congestion_congestion : 24;
    uint32_t                int_hop1_egressporttxutilization;

    uint32_t                int_hop2_swid;
    uint16_t                int_hop2_ingressport;
    uint16_t                int_hop2_egressport;
    uint32_t                int_hop2_hoplatency;
    uint32_t                int_hop2_occupancy_queueid   : 8;
    uint32_t                int_hop2_occupancy_occupancy : 24;
    uint32_t                int_hop2_ingresstimestamp;
    uint32_t                int_hop2_egresstimestamp;
    uint32_t                int_hop2_congestion_queueid    : 8;
    uint32_t                int_hop2_congestion_congestion : 24;
    uint32_t                int_hop2_egressporttxutilization;

    uint32_t                int_hop3_swid;
    uint16_t                int_hop3_ingressport;
    uint16_t                int_hop3_egressport;
    uint32_t                int_hop3_hoplatency;
    uint32_t                int_hop3_occupancy_queueid   : 8;
    uint32_t                int_hop3_occupancy_occupancy : 24;
    uint32_t                int_hop3_ingresstimestamp;
    uint32_t                int_hop3_egresstimestamp;
    uint32_t                int_hop3_congestion_queueid    : 8;
    uint32_t                int_hop3_congestion_congestion : 24;
    uint32_t                int_hop3_egressporttxutilization;

    uint32_t                int_hop4_swid;
    uint16_t                int_hop4_ingressport;
    uint16_t                int_hop4_egressport;
    uint32_t                int_hop4_hoplatency;
    uint32_t                int_hop4_occupancy_queueid   : 8;
    uint32_t                int_hop4_occupancy_occupancy : 24;
    uint32_t                int_hop4_ingresstimestamp;
    uint32_t                int_hop4_egresstimestamp;
    uint32_t                int_hop4_congestion_queueid    : 8;
    uint32_t                int_hop4_congestion_congestion : 24;
    uint32_t                int_hop4_egressporttxutilization;

    uint32_t                int_hop5_swid;
    uint16_t                int_hop5_ingressport;
    uint16_t                int_hop5_egressport;
    uint32_t                int_hop5_hoplatency;
    uint32_t                int_hop5_occupancy_queueid   : 8;
    uint32_t                int_hop5_occupancy_occupancy : 24;
    uint32_t                int_hop5_ingresstimestamp;
    uint32_t                int_hop5_egresstimestamp;
    uint32_t                int_hop5_congestion_queueid    : 8;
    uint32_t                int_hop5_congestion_congestion : 24;
    uint32_t                int_hop5_egressporttxutilization;
} np4_int_header_t;

/**
 * \brief Telemetry Report header
 */
struct __attribute__((__packed__)) telemetry_report
{
    uint8_t    nproto: 4;
    uint8_t    ver   : 4;
    uint16_t   res16;
    uint8_t    hw_id : 6;
    uint8_t    res2  : 2;
    uint32_t   sequence_number;
    uint32_t   ingress_timestamp;
};

/**
 * \brief Ethernet header
 */
struct __attribute__((__packed__)) ethernet
{
    uint8_t    dmac[6];
    uint8_t    smac[6];
    uint16_t   ethtype;
};

/**
 * \brief INT Shim header
 */
struct __attribute__((__packed__)) int_shim
{
    uint8_t    type;
    uint8_t    res1;
    uint8_t    length;
    uint8_t    res2;
};

/**
 * \brief INT header
 */
struct __attribute__((__packed__)) int_hdr
{
    uint8_t    res4 : 4;
    uint8_t    ver  : 4;
    uint8_t    ins_cnt : 5;
    uint8_t    res3    : 3;
    uint8_t    max_hop_cnt;
    uint8_t    total_hop_cnt;
    uint16_t   instr_bitmap;
    uint16_t   reserved;
};

/**
 * \brief INT Tail header
 */
struct __attribute__((__packed__)) int_tail
{
    uint8_t    proto;
    uint16_t   dport;
    uint8_t    dscp;
};

bool run = true;

/**
 * \brief Function for calculating IP checksum
 * @param vdata  Pointer to IP header
 * @param length Length of IP header
 * Source: http://www.microhowto.info/howto/calculate_an_internet_protocol_checksum_in_c.html
 */
uint16_t ip_checksum(void* vdata,size_t length) {
    // Cast the data pointer to one that can be indexed.
    char* data=(char*)vdata;

    // Initialise the accumulator.
    uint64_t acc=0xffff;

    // Handle any partial block at the start of the data.
    unsigned int offset=((uintptr_t)data)&3;
    if (offset) {
        size_t count=4-offset;
        if (count>length) count=length;
        uint32_t word=0;
        memcpy(offset+(char*)&word,data,count);
        acc+=ntohl(word);
        data+=count;
        length-=count;
    }

    // Handle any complete 32-bit blocks.
    char* data_end=data+(length&~3);
    while (data!=data_end) {
        uint32_t word;
        memcpy(&word,data,4);
        acc+=ntohl(word);
        data+=4;
    }
    length&=3;

    // Handle any partial block at the end of the data.
    if (length) {
        uint32_t word=0;
        memcpy(&word,data,length);
        acc+=ntohl(word);
    }

    // Handle deferred carries.
    acc=(acc&0xffffffff)+(acc>>32);
    while (acc>>16) {
        acc=(acc&0xffff)+(acc>>16);
    }

    // If the data began at an odd byte address
    // then reverse the byte order to compensate.
    if (offset&1) {
        acc=((acc&0xff00)>>8)|((acc&0x00ff)<<8);
    }

    // Return the checksum in network byte order.
    return htons(~acc);
}

/**
 * \brief Packet processing function.
 * @param np4  Netcope P4 instance
 * @param args Parsed command line arguments
 */
void np4_processing(np4_t* np4, arguments const &args) {
    np4_rx_stream_t *rx_stream = NULL; // Netcope P4 RX stream
    unsigned char *data;               // Pointer to Netcope P4 input
    unsigned data_len;                 // Length of Netcope P4 input
    np4_header_t np4_hdr;              // Netcope P4 frame header
    np4_int_header_t *np4_int_hdr;     // Netcope P4 INT header
    np4_error_t err;                   // Netcope P4 error type
    unsigned frame_len;

    // Telemetry report packet types
    int sock;
    struct sockaddr_in sockaddr;
    char buffer[512] = { 0 };
    uint32_t seqnum = 0;

    try {
        // Prepare socket for Telemetry reports
        if ((sock = socket(AF_INET, SOCK_RAW, IPPROTO_RAW)) == -1) {
            throw std::string("Socket error");
        }
        memset((char *) &sockaddr, 0, sizeof(sockaddr));
        sockaddr.sin_family = AF_INET;
        if (inet_aton(args.ip, &sockaddr.sin_addr) == 0)
        {
            throw std::string("IP address error");
        }

        // Prepare common IP header for Telemetry reports
        struct iphdr *ip = (struct iphdr *) &(buffer[0]);
        ip->ihl = 5;
        ip->version = 4;
        ip->tos = 0;
        ip->tot_len = 0;
        ip->id = 0;
        ip->frag_off = htons(0x4000);
        ip->ttl = 255;
        ip->protocol = 17;
        ip->check = 0;
        ip->saddr = 0;
        ip->daddr = sockaddr.sin_addr.s_addr;

        // Prepare common UDP header for Telemetry reports
        struct udphdr *udp = (struct udphdr *) &(buffer[20]);
        udp->source = 0;
        udp->dest = htons(args.port);
        udp->len = 0;
        udp->check = 0;

        // Open Netcope P4 RX stream
        err = np4_rx_stream_open(np4, args.rx_queue, &rx_stream);
        // Main processing loop
        while(run) {
            // Rry to read next Netcope P4 input
            data = np4_rx_stream_read_next(rx_stream, &data_len);
            // New Netcope P4 input
            if(data) {
                // Check length of Netcope INT header
                if (data_len == 256) {
                    // Parse Netcope P4 input into Netcope P4 header and Netcope INT header
                    err = np4_parse_frame(data, &np4_hdr, (unsigned char **) &np4_int_hdr, &frame_len);
                    if (err) {
                        throw np4_print_error(err);
                    }

                    // Debug output
                    if (args.verbose) {
                        std::cout << "Received INT header" << std::endl;
                        std::cout << "\tFlow ID:" << std::endl;
                        std::cout << "\t\tTimestamp           : " << np4_hdr.timestamp_s << "." << np4_hdr.timestamp_ns << std::endl;
                        std::cout << "\t\tInterface           : " << (unsigned) np4_hdr.iface << std::endl;
                        std::cout << "\t\tIP version          : " << (unsigned) np4_int_hdr->ip_ver << std::endl;
                        std::cout << "\t\tSource IPv4         : "
                                    << ((np4_int_hdr->source_ip[0] >> 24) & 0xFF) << "."
                                    << ((np4_int_hdr->source_ip[0] >> 16) & 0xFF) << "."
                                    << ((np4_int_hdr->source_ip[0] >> 8) & 0xFF) << "."
                                    << ((np4_int_hdr->source_ip[0] & 0xFF)) << std::endl;
                        std::cout << "\t\tDestination IPv4    : "
                                    << ((np4_int_hdr->destination_ip[0] >> 24) & 0xFF) << "."
                                    << ((np4_int_hdr->destination_ip[0] >> 16) & 0xFF) << "."
                                    << ((np4_int_hdr->destination_ip[0] >> 8) & 0xFF) << "."
                                    << ((np4_int_hdr->destination_ip[0] & 0xFF)) << std::endl;
                        std::cout << "\t\tL4 protocol         : " << (unsigned) np4_int_hdr->l4_proto << std::endl;
                        std::cout << "\t\tSource L4 port      : " << np4_int_hdr->source_port << std::endl;
                        std::cout << "\t\tDestination L4 port : " << np4_int_hdr->destination_port << std::endl;
                        std::cout << std::endl;
                        // If INT was detected
                        if (np4_int_hdr->int_vld) {
                            std::cout << "\tINT common:"  << std::endl;
                            std::cout << "\t\tLength              : " << (unsigned) np4_int_hdr->int_length << std::endl;
                            std::cout << "\t\tInstruction count   : " << (unsigned) np4_int_hdr->int_inscnt << std::endl;
                            std::cout << "\t\tInstruction map     : " << std::bitset<16>(np4_int_hdr->int_insmap) << std::endl;
                            std::cout << std::endl;
                            // If INT Hop 0 was detected
                            if (np4_int_hdr->int_hop0_vld) {
                                std::cout << "\tINT hop 0:" << std::endl;
                                if (np4_int_hdr->int_insmap & 0x8000) std::cout << "\t\tSwitch ID           : " << np4_int_hdr->int_hop0_swid << std::endl;
                                if (np4_int_hdr->int_insmap & 0x4000) std::cout << "\t\tIngress port        : " << np4_int_hdr->int_hop0_ingressport << std::endl;
                                if (np4_int_hdr->int_insmap & 0x4000) std::cout << "\t\tEgress port         : " << np4_int_hdr->int_hop0_egressport << std::endl;
                                if (np4_int_hdr->int_insmap & 0x2000) std::cout << "\t\tHop latency         : " << np4_int_hdr->int_hop0_hoplatency << std::endl;
                                if (np4_int_hdr->int_insmap & 0x1000) std::cout << "\t\tQueue occupancy     : " << np4_int_hdr->int_hop0_occupancy_queueid << " : " << np4_int_hdr->int_hop0_occupancy_occupancy << std::endl;
                                if (np4_int_hdr->int_insmap & 0x0800) std::cout << "\t\tIngress timestamp   : " << np4_int_hdr->int_hop0_ingresstimestamp << std::endl;
                                if (np4_int_hdr->int_insmap & 0x0400) std::cout << "\t\tEgress timestamp    : " << np4_int_hdr->int_hop0_egresstimestamp << std::endl;
                                if (np4_int_hdr->int_insmap & 0x0200) std::cout << "\t\tQueue congestion    : " << np4_int_hdr->int_hop0_congestion_queueid << " : " << np4_int_hdr->int_hop0_congestion_congestion << std::endl;
                                if (np4_int_hdr->int_insmap & 0x0100) std::cout << "\t\tEgress port TX util.: " << np4_int_hdr->int_hop0_egressporttxutilization << std::endl;
                            }
                            // If INT Hop 1 was detected
                            if (np4_int_hdr->int_hop1_vld) {
                                std::cout << "\tINT hop 1:" << std::endl;
                                if (np4_int_hdr->int_insmap & 0x8000) std::cout << "\t\tSwitch ID           : " << np4_int_hdr->int_hop1_swid << std::endl;
                                if (np4_int_hdr->int_insmap & 0x4000) std::cout << "\t\tIngress port        : " << np4_int_hdr->int_hop1_ingressport << std::endl;
                                if (np4_int_hdr->int_insmap & 0x4000) std::cout << "\t\tEgress port         : " << np4_int_hdr->int_hop1_egressport << std::endl;
                                if (np4_int_hdr->int_insmap & 0x2000) std::cout << "\t\tHop latency         : " << np4_int_hdr->int_hop1_hoplatency << std::endl;
                                if (np4_int_hdr->int_insmap & 0x1000) std::cout << "\t\tQueue occupancy     : " << np4_int_hdr->int_hop1_occupancy_queueid << " : " << np4_int_hdr->int_hop1_occupancy_occupancy << std::endl;
                                if (np4_int_hdr->int_insmap & 0x0800) std::cout << "\t\tIngress timestamp   : " << np4_int_hdr->int_hop1_ingresstimestamp << std::endl;
                                if (np4_int_hdr->int_insmap & 0x0400) std::cout << "\t\tEgress timestamp    : " << np4_int_hdr->int_hop1_egresstimestamp << std::endl;
                                if (np4_int_hdr->int_insmap & 0x0200) std::cout << "\t\tQueue congestion    : " << np4_int_hdr->int_hop1_congestion_queueid << " : " << np4_int_hdr->int_hop1_congestion_congestion << std::endl;
                                if (np4_int_hdr->int_insmap & 0x0100) std::cout << "\t\tEgress port TX util.: " << np4_int_hdr->int_hop1_egressporttxutilization << std::endl;
                            }
                            // If INT Hop 2 was detected
                            if (np4_int_hdr->int_hop2_vld) {
                                std::cout << "\tINT hop 2:" << std::endl;
                                if (np4_int_hdr->int_insmap & 0x8000) std::cout << "\t\tSwitch ID           : " << np4_int_hdr->int_hop2_swid << std::endl;
                                if (np4_int_hdr->int_insmap & 0x4000) std::cout << "\t\tIngress port        : " << np4_int_hdr->int_hop2_ingressport << std::endl;
                                if (np4_int_hdr->int_insmap & 0x4000) std::cout << "\t\tEgress port         : " << np4_int_hdr->int_hop2_egressport << std::endl;
                                if (np4_int_hdr->int_insmap & 0x2000) std::cout << "\t\tHop latency         : " << np4_int_hdr->int_hop2_hoplatency << std::endl;
                                if (np4_int_hdr->int_insmap & 0x1000) std::cout << "\t\tQueue occupancy     : " << np4_int_hdr->int_hop2_occupancy_queueid << " : " << np4_int_hdr->int_hop2_occupancy_occupancy << std::endl;
                                if (np4_int_hdr->int_insmap & 0x0800) std::cout << "\t\tIngress timestamp   : " << np4_int_hdr->int_hop2_ingresstimestamp << std::endl;
                                if (np4_int_hdr->int_insmap & 0x0400) std::cout << "\t\tEgress timestamp    : " << np4_int_hdr->int_hop2_egresstimestamp << std::endl;
                                if (np4_int_hdr->int_insmap & 0x0200) std::cout << "\t\tQueue congestion    : " << np4_int_hdr->int_hop2_congestion_queueid << " : " << np4_int_hdr->int_hop2_congestion_congestion << std::endl;
                                if (np4_int_hdr->int_insmap & 0x0100) std::cout << "\t\tEgress port TX util.: " << np4_int_hdr->int_hop2_egressporttxutilization << std::endl;
                            }
                            // If INT Hop 3 was detected
                            if (np4_int_hdr->int_hop3_vld) {
                                std::cout << "\tINT hop 3:" << std::endl;
                                if (np4_int_hdr->int_insmap & 0x8000) std::cout << "\t\tSwitch ID           : " << np4_int_hdr->int_hop3_swid << std::endl;
                                if (np4_int_hdr->int_insmap & 0x4000) std::cout << "\t\tIngress port        : " << np4_int_hdr->int_hop3_ingressport << std::endl;
                                if (np4_int_hdr->int_insmap & 0x4000) std::cout << "\t\tEgress port         : " << np4_int_hdr->int_hop3_egressport << std::endl;
                                if (np4_int_hdr->int_insmap & 0x2000) std::cout << "\t\tHop latency         : " << np4_int_hdr->int_hop3_hoplatency << std::endl;
                                if (np4_int_hdr->int_insmap & 0x1000) std::cout << "\t\tQueue occupancy     : " << np4_int_hdr->int_hop3_occupancy_queueid << " : " << np4_int_hdr->int_hop3_occupancy_occupancy << std::endl;
                                if (np4_int_hdr->int_insmap & 0x0800) std::cout << "\t\tIngress timestamp   : " << np4_int_hdr->int_hop3_ingresstimestamp << std::endl;
                                if (np4_int_hdr->int_insmap & 0x0400) std::cout << "\t\tEgress timestamp    : " << np4_int_hdr->int_hop3_egresstimestamp << std::endl;
                                if (np4_int_hdr->int_insmap & 0x0200) std::cout << "\t\tQueue congestion    : " << np4_int_hdr->int_hop3_congestion_queueid << " : " << np4_int_hdr->int_hop3_congestion_congestion << std::endl;
                                if (np4_int_hdr->int_insmap & 0x0100) std::cout << "\t\tEgress port TX util.: " << np4_int_hdr->int_hop3_egressporttxutilization << std::endl;
                            }
                            // If INT Hop 4 was detected
                            if (np4_int_hdr->int_hop4_vld) {
                                std::cout << "\tINT hop 4:" << std::endl;
                                if (np4_int_hdr->int_insmap & 0x8000) std::cout << "\t\tSwitch ID           : " << np4_int_hdr->int_hop4_swid << std::endl;
                                if (np4_int_hdr->int_insmap & 0x4000) std::cout << "\t\tIngress port        : " << np4_int_hdr->int_hop4_ingressport << std::endl;
                                if (np4_int_hdr->int_insmap & 0x4000) std::cout << "\t\tEgress port         : " << np4_int_hdr->int_hop4_egressport << std::endl;
                                if (np4_int_hdr->int_insmap & 0x2000) std::cout << "\t\tHop latency         : " << np4_int_hdr->int_hop4_hoplatency << std::endl;
                                if (np4_int_hdr->int_insmap & 0x1000) std::cout << "\t\tQueue occupancy     : " << np4_int_hdr->int_hop4_occupancy_queueid << " : " << np4_int_hdr->int_hop4_occupancy_occupancy << std::endl;
                                if (np4_int_hdr->int_insmap & 0x0800) std::cout << "\t\tIngress timestamp   : " << np4_int_hdr->int_hop4_ingresstimestamp << std::endl;
                                if (np4_int_hdr->int_insmap & 0x0400) std::cout << "\t\tEgress timestamp    : " << np4_int_hdr->int_hop4_egresstimestamp << std::endl;
                                if (np4_int_hdr->int_insmap & 0x0200) std::cout << "\t\tQueue congestion    : " << np4_int_hdr->int_hop4_congestion_queueid << " : " << np4_int_hdr->int_hop4_congestion_congestion << std::endl;
                                if (np4_int_hdr->int_insmap & 0x0100) std::cout << "\t\tEgress port TX util.: " << np4_int_hdr->int_hop4_egressporttxutilization << std::endl;
                            }
                            // If INT Hop 5 was detected
                            if (np4_int_hdr->int_hop5_vld) {
                                std::cout << "\tINT hop 5:" << std::endl;
                                if (np4_int_hdr->int_insmap & 0x8000) std::cout << "\t\tSwitch ID           : " << np4_int_hdr->int_hop5_swid << std::endl;
                                if (np4_int_hdr->int_insmap & 0x4000) std::cout << "\t\tIngress port        : " << np4_int_hdr->int_hop5_ingressport << std::endl;
                                if (np4_int_hdr->int_insmap & 0x4000) std::cout << "\t\tEgress port         : " << np4_int_hdr->int_hop5_egressport << std::endl;
                                if (np4_int_hdr->int_insmap & 0x2000) std::cout << "\t\tHop latency         : " << np4_int_hdr->int_hop5_hoplatency << std::endl;
                                if (np4_int_hdr->int_insmap & 0x1000) std::cout << "\t\tQueue occupancy     : " << np4_int_hdr->int_hop5_occupancy_queueid << " : " << np4_int_hdr->int_hop5_occupancy_occupancy << std::endl;
                                if (np4_int_hdr->int_insmap & 0x0800) std::cout << "\t\tIngress timestamp   : " << np4_int_hdr->int_hop5_ingresstimestamp << std::endl;
                                if (np4_int_hdr->int_insmap & 0x0400) std::cout << "\t\tEgress timestamp    : " << np4_int_hdr->int_hop5_egresstimestamp << std::endl;
                                if (np4_int_hdr->int_insmap & 0x0200) std::cout << "\t\tQueue congestion    : " << np4_int_hdr->int_hop5_congestion_queueid << " : " << np4_int_hdr->int_hop5_congestion_congestion << std::endl;
                                if (np4_int_hdr->int_insmap & 0x0100) std::cout << "\t\tEgress port TX util.: " << np4_int_hdr->int_hop5_egressporttxutilization << std::endl;
                            }
                        } else {
                            std::cout << "\tINT not detected." << std::endl;
                        }
                    }

                    // Prepare and send Telemetry report if INT was detected
                    if (np4_int_hdr->int_vld) {
                        // Prepare Telemetry report header
                        struct telemetry_report *tel = (struct telemetry_report *) &(buffer[28]);
                        tel->ver = 0;
                        tel->nproto = 0;
                        tel->res16 = htons(0x2000);
                        tel->res2 = 0;
                        tel->hw_id = 1;
                        tel->sequence_number = htonl(++seqnum);
                        tel->ingress_timestamp = htonl(np4_hdr.timestamp_s);

                        // Prepare Ethernet header
                        struct ethernet *eth_in = (struct ethernet *) &(buffer[40]);
                        eth_in->dmac[0] = 0x01; eth_in->dmac[1] = 0x02; eth_in->dmac[2] = 0x03; eth_in->dmac[3] = 0x04; eth_in->dmac[4] = 0x05; eth_in->dmac[5] = 0x06; // Static
                        eth_in->smac[0] = 0x11; eth_in->smac[1] = 0x12; eth_in->smac[2] = 0x13; eth_in->smac[3] = 0x14; eth_in->smac[4] = 0x15; eth_in->smac[5] = 0x16; // Static
                        eth_in->ethtype = htons(0x0800); // Static

                        // Prepare Ethernet header
                        struct iphdr *ip_in = (struct iphdr *) &(buffer[54]);
                        ip_in->ihl = 5; // Static
                        ip_in->version = 4; // Static
                        ip_in->tos = 0x04; // Static
                        ip_in->tot_len = 0; // Actual length is used
                        ip_in->id = 0; // Static
                        ip_in->frag_off = htons(0x4000); // Static
                        ip_in->ttl = 255; // Static
                        ip_in->protocol = np4_int_hdr->l4_proto;
                        ip_in->check = 0; // Actual checksum is used
                        ip_in->saddr = htonl(np4_int_hdr->source_ip[0]);
                        ip_in->daddr = htonl(np4_int_hdr->destination_ip[0]);

                        unsigned l4_in_size;
                        struct tcphdr *tcp_in;
                        struct udphdr *udp_in;
                        if (ip_in->protocol == 6) {
                            l4_in_size = 20;
                            // Prepare TCP header
                            tcp_in = (struct tcphdr *) &(buffer[74]);
                            tcp_in->source = htons(np4_int_hdr->source_port);
                            tcp_in->dest = htons(np4_int_hdr->destination_port);
                            tcp_in->seq = 0;
                            tcp_in->ack_seq = 0;
                            tcp_in->res1 = 0;
                            tcp_in->doff = 5;
                            tcp_in->fin = 0;
                            tcp_in->syn = 0;
                            tcp_in->rst = 0;
                            tcp_in->psh = 0;
                            tcp_in->ack = 0;
                            tcp_in->urg = 0;
                            tcp_in->res2 = 0;
                            tcp_in->window = 0;
                            tcp_in->check = 0;
                            tcp_in->urg_ptr = 0;
                        } else {
                            l4_in_size = 8;
                            // Prepare UDP header
                            udp_in = (struct udphdr *) &(buffer[74]);
                            udp_in->source = htons(np4_int_hdr->source_port);
                            udp_in->dest = htons(np4_int_hdr->destination_port);
                            udp_in->len = 0; // Actual length is used
                            udp_in->check = 0; // Static
                        }

                        // Prepare INT Shim header
                        struct int_shim *int_sh = (struct int_shim *) &(buffer[74+l4_in_size]);
                        int_sh->type = 1; // Static
                        int_sh->res1 = 0;
                        int_sh->length = np4_int_hdr->int_length;
                        int_sh->res2 = 0;

                        // Prepare INT header
                        struct int_hdr *int_h = (struct int_hdr *) &(buffer[74+l4_in_size+4]);
                        int_h->ver = 0; // Static
                        int_h->res4 = 0;
                        int_h->ins_cnt = np4_int_hdr->int_inscnt;
                        int_h->res3 = 0;
                        int_h->max_hop_cnt = 0; // Static
                        int_h->total_hop_cnt = 0; // Static
                        if (np4_int_hdr->int_hop0_vld) int_h->total_hop_cnt++;
                        if (np4_int_hdr->int_hop1_vld) int_h->total_hop_cnt++;
                        if (np4_int_hdr->int_hop2_vld) int_h->total_hop_cnt++;
                        if (np4_int_hdr->int_hop3_vld) int_h->total_hop_cnt++;
                        if (np4_int_hdr->int_hop4_vld) int_h->total_hop_cnt++;
                        if (np4_int_hdr->int_hop5_vld) int_h->total_hop_cnt++;
                        int_h->instr_bitmap = htons(np4_int_hdr->int_insmap);
                        int_h->reserved = 0;

                        unsigned index = 74+l4_in_size+4+8;
                        if (np4_int_hdr->int_hop5_vld) {
                            if (np4_int_hdr->int_insmap & 0x8000) { *((uint32_t *) &(buffer[index])) = htonl(np4_int_hdr->int_hop5_swid); index += 4; }
                            if (np4_int_hdr->int_insmap & 0x4000) { *((uint16_t *) &(buffer[index])) = htons(np4_int_hdr->int_hop5_ingressport); index += 2; }
                            if (np4_int_hdr->int_insmap & 0x4000) { *((uint16_t *) &(buffer[index])) = htons(np4_int_hdr->int_hop5_egressport); index += 2; }
                            if (np4_int_hdr->int_insmap & 0x2000) { *((uint32_t *) &(buffer[index])) = htonl(np4_int_hdr->int_hop5_hoplatency); index += 4; }
                            if (np4_int_hdr->int_insmap & 0x1000) { *((uint8_t  *) &(buffer[index])) = np4_int_hdr->int_hop5_occupancy_queueid; index += 1; }
                            if (np4_int_hdr->int_insmap & 0x1000) { *((uint32_t *) &(buffer[index])) = htonl(np4_int_hdr->int_hop5_occupancy_occupancy)>>8; index += 3; }
                            if (np4_int_hdr->int_insmap & 0x0800) { *((uint32_t *) &(buffer[index])) = htonl(np4_int_hdr->int_hop5_ingresstimestamp); index += 4; }
                            if (np4_int_hdr->int_insmap & 0x0400) { *((uint32_t *) &(buffer[index])) = htonl(np4_int_hdr->int_hop5_egresstimestamp); index += 4; }
                            if (np4_int_hdr->int_insmap & 0x0200) { *((uint8_t  *) &(buffer[index])) = np4_int_hdr->int_hop5_congestion_queueid; index += 1; }
                            if (np4_int_hdr->int_insmap & 0x0200) { *((uint32_t *) &(buffer[index])) = htonl(np4_int_hdr->int_hop5_congestion_congestion)>>8; index += 3; }
                            if (np4_int_hdr->int_insmap & 0x0100) { *((uint32_t *) &(buffer[index])) = htonl(np4_int_hdr->int_hop5_egressporttxutilization); index += 4; }
                        }
                        if (np4_int_hdr->int_hop4_vld) {
                            if (np4_int_hdr->int_insmap & 0x8000) { *((uint32_t *) &(buffer[index])) = htonl(np4_int_hdr->int_hop4_swid); index += 4; }
                            if (np4_int_hdr->int_insmap & 0x4000) { *((uint16_t *) &(buffer[index])) = htons(np4_int_hdr->int_hop4_ingressport); index += 2; }
                            if (np4_int_hdr->int_insmap & 0x4000) { *((uint16_t *) &(buffer[index])) = htons(np4_int_hdr->int_hop4_egressport); index += 2; }
                            if (np4_int_hdr->int_insmap & 0x2000) { *((uint32_t *) &(buffer[index])) = htonl(np4_int_hdr->int_hop4_hoplatency); index += 4; }
                            if (np4_int_hdr->int_insmap & 0x1000) { *((uint8_t  *) &(buffer[index])) = np4_int_hdr->int_hop4_occupancy_queueid; index += 1; }
                            if (np4_int_hdr->int_insmap & 0x1000) { *((uint32_t *) &(buffer[index])) = htonl(np4_int_hdr->int_hop4_occupancy_occupancy)>>8; index += 3; }
                            if (np4_int_hdr->int_insmap & 0x0800) { *((uint32_t *) &(buffer[index])) = htonl(np4_int_hdr->int_hop4_ingresstimestamp); index += 4; }
                            if (np4_int_hdr->int_insmap & 0x0400) { *((uint32_t *) &(buffer[index])) = htonl(np4_int_hdr->int_hop4_egresstimestamp); index += 4; }
                            if (np4_int_hdr->int_insmap & 0x0200) { *((uint8_t  *) &(buffer[index])) = np4_int_hdr->int_hop4_congestion_queueid; index += 1; }
                            if (np4_int_hdr->int_insmap & 0x0200) { *((uint32_t *) &(buffer[index])) = htonl(np4_int_hdr->int_hop4_congestion_congestion)>>8; index += 3; }
                            if (np4_int_hdr->int_insmap & 0x0100) { *((uint32_t *) &(buffer[index])) = htonl(np4_int_hdr->int_hop4_egressporttxutilization); index += 4; }
                        }
                        if (np4_int_hdr->int_hop3_vld) {
                            if (np4_int_hdr->int_insmap & 0x8000) { *((uint32_t *) &(buffer[index])) = htonl(np4_int_hdr->int_hop3_swid); index += 4; }
                            if (np4_int_hdr->int_insmap & 0x4000) { *((uint16_t *) &(buffer[index])) = htons(np4_int_hdr->int_hop3_ingressport); index += 2; }
                            if (np4_int_hdr->int_insmap & 0x4000) { *((uint16_t *) &(buffer[index])) = htons(np4_int_hdr->int_hop3_egressport); index += 2; }
                            if (np4_int_hdr->int_insmap & 0x2000) { *((uint32_t *) &(buffer[index])) = htonl(np4_int_hdr->int_hop3_hoplatency); index += 4; }
                            if (np4_int_hdr->int_insmap & 0x1000) { *((uint8_t  *) &(buffer[index])) = np4_int_hdr->int_hop3_occupancy_queueid; index += 1; }
                            if (np4_int_hdr->int_insmap & 0x1000) { *((uint32_t *) &(buffer[index])) = htonl(np4_int_hdr->int_hop3_occupancy_occupancy)>>8; index += 3; }
                            if (np4_int_hdr->int_insmap & 0x0800) { *((uint32_t *) &(buffer[index])) = htonl(np4_int_hdr->int_hop3_ingresstimestamp); index += 4; }
                            if (np4_int_hdr->int_insmap & 0x0400) { *((uint32_t *) &(buffer[index])) = htonl(np4_int_hdr->int_hop3_egresstimestamp); index += 4; }
                            if (np4_int_hdr->int_insmap & 0x0200) { *((uint8_t  *) &(buffer[index])) = np4_int_hdr->int_hop3_congestion_queueid; index += 1; }
                            if (np4_int_hdr->int_insmap & 0x0200) { *((uint32_t *) &(buffer[index])) = htonl(np4_int_hdr->int_hop3_congestion_congestion)>>8; index += 3; }
                            if (np4_int_hdr->int_insmap & 0x0100) { *((uint32_t *) &(buffer[index])) = htonl(np4_int_hdr->int_hop3_egressporttxutilization); index += 4; }
                        }
                        if (np4_int_hdr->int_hop2_vld) {
                            if (np4_int_hdr->int_insmap & 0x8000) { *((uint32_t *) &(buffer[index])) = htonl(np4_int_hdr->int_hop2_swid); index += 4; }
                            if (np4_int_hdr->int_insmap & 0x4000) { *((uint16_t *) &(buffer[index])) = htons(np4_int_hdr->int_hop2_ingressport); index += 2; }
                            if (np4_int_hdr->int_insmap & 0x4000) { *((uint16_t *) &(buffer[index])) = htons(np4_int_hdr->int_hop2_egressport); index += 2; }
                            if (np4_int_hdr->int_insmap & 0x2000) { *((uint32_t *) &(buffer[index])) = htonl(np4_int_hdr->int_hop2_hoplatency); index += 4; }
                            if (np4_int_hdr->int_insmap & 0x1000) { *((uint8_t  *) &(buffer[index])) = np4_int_hdr->int_hop2_occupancy_queueid; index += 1; }
                            if (np4_int_hdr->int_insmap & 0x1000) { *((uint32_t *) &(buffer[index])) = htonl(np4_int_hdr->int_hop2_occupancy_occupancy)>>8; index += 3; }
                            if (np4_int_hdr->int_insmap & 0x0800) { *((uint32_t *) &(buffer[index])) = htonl(np4_int_hdr->int_hop2_ingresstimestamp); index += 4; }
                            if (np4_int_hdr->int_insmap & 0x0400) { *((uint32_t *) &(buffer[index])) = htonl(np4_int_hdr->int_hop2_egresstimestamp); index += 4; }
                            if (np4_int_hdr->int_insmap & 0x0200) { *((uint8_t  *) &(buffer[index])) = np4_int_hdr->int_hop2_congestion_queueid; index += 1; }
                            if (np4_int_hdr->int_insmap & 0x0200) { *((uint32_t *) &(buffer[index])) = htonl(np4_int_hdr->int_hop2_congestion_congestion)>>8; index += 3; }
                            if (np4_int_hdr->int_insmap & 0x0100) { *((uint32_t *) &(buffer[index])) = htonl(np4_int_hdr->int_hop2_egressporttxutilization); index += 4; }
                        }
                        if (np4_int_hdr->int_hop1_vld) {
                            if (np4_int_hdr->int_insmap & 0x8000) { *((uint32_t *) &(buffer[index])) = htonl(np4_int_hdr->int_hop1_swid); index += 4; }
                            if (np4_int_hdr->int_insmap & 0x4000) { *((uint16_t *) &(buffer[index])) = htons(np4_int_hdr->int_hop1_ingressport); index += 2; }
                            if (np4_int_hdr->int_insmap & 0x4000) { *((uint16_t *) &(buffer[index])) = htons(np4_int_hdr->int_hop1_egressport); index += 2; }
                            if (np4_int_hdr->int_insmap & 0x2000) { *((uint32_t *) &(buffer[index])) = htonl(np4_int_hdr->int_hop1_hoplatency); index += 4; }
                            if (np4_int_hdr->int_insmap & 0x1000) { *((uint8_t  *) &(buffer[index])) = np4_int_hdr->int_hop1_occupancy_queueid; index += 1; }
                            if (np4_int_hdr->int_insmap & 0x1000) { *((uint32_t *) &(buffer[index])) = htonl(np4_int_hdr->int_hop1_occupancy_occupancy)>>8; index += 3; }
                            if (np4_int_hdr->int_insmap & 0x0800) { *((uint32_t *) &(buffer[index])) = htonl(np4_int_hdr->int_hop1_ingresstimestamp); index += 4; }
                            if (np4_int_hdr->int_insmap & 0x0400) { *((uint32_t *) &(buffer[index])) = htonl(np4_int_hdr->int_hop1_egresstimestamp); index += 4; }
                            if (np4_int_hdr->int_insmap & 0x0200) { *((uint8_t  *) &(buffer[index])) = np4_int_hdr->int_hop1_congestion_queueid; index += 1; }
                            if (np4_int_hdr->int_insmap & 0x0200) { *((uint32_t *) &(buffer[index])) = htonl(np4_int_hdr->int_hop1_congestion_congestion)>>8; index += 3; }
                            if (np4_int_hdr->int_insmap & 0x0100) { *((uint32_t *) &(buffer[index])) = htonl(np4_int_hdr->int_hop1_egressporttxutilization); index += 4; }
                        }
                        if (np4_int_hdr->int_hop0_vld) {
                            if (np4_int_hdr->int_insmap & 0x8000) { *((uint32_t *) &(buffer[index])) = htonl(np4_int_hdr->int_hop0_swid); index += 4; }
                            if (np4_int_hdr->int_insmap & 0x4000) { *((uint16_t *) &(buffer[index])) = htons(np4_int_hdr->int_hop0_ingressport); index += 2; }
                            if (np4_int_hdr->int_insmap & 0x4000) { *((uint16_t *) &(buffer[index])) = htons(np4_int_hdr->int_hop0_egressport); index += 2; }
                            if (np4_int_hdr->int_insmap & 0x2000) { *((uint32_t *) &(buffer[index])) = htonl(np4_int_hdr->int_hop0_hoplatency); index += 4; }
                            if (np4_int_hdr->int_insmap & 0x1000) { *((uint8_t  *) &(buffer[index])) = np4_int_hdr->int_hop0_occupancy_queueid; index += 1; }
                            if (np4_int_hdr->int_insmap & 0x1000) { *((uint32_t *) &(buffer[index])) = htonl(np4_int_hdr->int_hop0_occupancy_occupancy)>>8; index += 3; }
                            if (np4_int_hdr->int_insmap & 0x0800) { *((uint32_t *) &(buffer[index])) = htonl(np4_int_hdr->int_hop0_ingresstimestamp); index += 4; }
                            if (np4_int_hdr->int_insmap & 0x0400) { *((uint32_t *) &(buffer[index])) = htonl(np4_int_hdr->int_hop0_egresstimestamp); index += 4; }
                            if (np4_int_hdr->int_insmap & 0x0200) { *((uint8_t  *) &(buffer[index])) = np4_int_hdr->int_hop0_congestion_queueid; index += 1; }
                            if (np4_int_hdr->int_insmap & 0x0200) { *((uint32_t *) &(buffer[index])) = htonl(np4_int_hdr->int_hop0_congestion_congestion)>>8; index += 3; }
                            if (np4_int_hdr->int_insmap & 0x0100) { *((uint32_t *) &(buffer[index])) = htonl(np4_int_hdr->int_hop0_egressporttxutilization); index += 4; }
                        }

                        // Prepare INT Tail header
                        struct int_tail *int_tl = (struct int_tail *) &(buffer[74+l4_in_size+(int_sh->length<<2)-4]);
                        int_tl->proto = ip_in->protocol;
                        int_tl->dport = (ip_in->protocol == 6) ? tcp_in->dest : udp_in->dest;
                        int_tl->dscp = 0; // Static

                        // Prepare payload
                        char *payload = (char *) &(buffer[74+l4_in_size+(int_sh->length<<2)]);
                        strncpy(payload, "Hello World", 11);

                        // Update lengths and checksums
                        udp->len = htons(8+12+14+20+l4_in_size+(int_sh->length<<2)+11);
                        ip_in->tot_len = htons(20+l4_in_size+(int_sh->length<<2)+11);
                        ip_in->check = ip_checksum(ip_in, 20);
                        if (ip_in->protocol == 17) udp_in->len = htons(l4_in_size+(int_sh->length<<2)+11);

                        // Send Telemetry report
                        if (sendto(sock, buffer, 20+8+12+14+20+l4_in_size+(int_sh->length<<2)+11, 0 , (struct sockaddr *) &sockaddr, sizeof(sockaddr)) == -1)
                        {
                            throw std::string("Packet send error");
                        }
                    }
                } else {
                    std::cerr << "Unexpected frame size (" << data_len << ")" << std::endl;
                }
            }
        }
    } catch(std::exception &e) {
        run = false;
        std::cerr << std::string() + __progname + ": " + e.what() + "\n";
    } catch(np4_error_t &e) {
        run = false;
    } catch(std::string message) {
        std::cerr << message << std::endl;
        run = false;
    }

    // Close Telemetry reports socket
    close(sock);

    // Close data receiving SZE channel
    if(rx_stream)
        np4_rx_stream_close(np4, &rx_stream);
}

/**
 * \brief Netcope P4 preparation function.
 * @param args Parsed command line arguments
 * @param np4  Netcope P4 instance
 */
inline void np4_preparation(arguments &args, np4_t **np4) {
    // Initialize Netcope P4
    np4_error_t err = np4_init_card(np4, args.card_id);
    if(err)
        throw np4_print_error(err);

    // Enable TX
    err = np4_tx_enable(*np4);
    if(err)
        throw np4_print_error(err);

    // Clear all tables (to not interfere with the rules we are about to load)
    //np4_core_reset(*np4, 0);

    // Create Netcope P4 ruleset
    np4_ruleset_t *ruleset = np4_ruleset_create(*np4, 0);
    np4_rule_t *rule;

    // Setting Netcope P4 tables
    if (args.original) {
        //// tab_remove_int
        // 1. Create default rule
        err = np4_rule_create(&rule, ruleset, "tab_remove_int");
        if(err) {
            np4_ruleset_free(ruleset);
            throw np4_print_error(err);
        }
        err = np4_rule_mark_default(rule);
        if(err) {
            np4_ruleset_free(ruleset);
            throw np4_print_error(err);
        }
        // 2. Set action of the rule
        err = np4_rule_set_action(rule,"permit");
        if(err) {
            np4_ruleset_free(ruleset);
            throw np4_print_error(err);
        }

        //// tab_update_enc_L4
        // 1. Create default rule
        err = np4_rule_create(&rule, ruleset, "tab_update_enc_L4");
        if(err) {
            np4_ruleset_free(ruleset);
            throw np4_print_error(err);
        }
        err = np4_rule_mark_default(rule);
        if(err) {
            np4_ruleset_free(ruleset);
            throw np4_print_error(err);
        }
        // 2. Set action of the rule
        err = np4_rule_set_action(rule,"permit");
        if(err) {
            np4_ruleset_free(ruleset);
            throw np4_print_error(err);
        }

        //// tab_update_L4
        // 1. Create default rule
        err = np4_rule_create(&rule, ruleset, "tab_update_L4");
        if(err) {
            np4_ruleset_free(ruleset);
            throw np4_print_error(err);
        }
        err = np4_rule_mark_default(rule);
        if(err) {
            np4_ruleset_free(ruleset);
            throw np4_print_error(err);
        }
        // 2. Set action of the rule
        err = np4_rule_set_action(rule,"permit");
        if(err) {
            np4_ruleset_free(ruleset);
            throw np4_print_error(err);
        }

        //// tab_terminate_gtp
        // 1. Create default rule
        err = np4_rule_create(&rule, ruleset, "tab_terminate_gtp");
        if(err) {
            np4_ruleset_free(ruleset);
            throw np4_print_error(err);
        }
        err = np4_rule_mark_default(rule);
        if(err) {
            np4_ruleset_free(ruleset);
            throw np4_print_error(err);
        }
        // 2. Set action of the rule
        err = np4_rule_set_action(rule,"permit");
        if(err) {
            np4_ruleset_free(ruleset);
            throw np4_print_error(err);
        }

    } else {
        //// tab_remove_int
        // 1. Create default rule
        err = np4_rule_create(&rule, ruleset, "tab_remove_int");
        if(err) {
            np4_ruleset_free(ruleset);
            throw np4_print_error(err);
        }
        err = np4_rule_mark_default(rule);
        if(err) {
            np4_ruleset_free(ruleset);
            throw np4_print_error(err);
        }
        // 2. Set action of the rule
        err = np4_rule_set_action(rule,"act_remove_int");
        if(err) {
            np4_ruleset_free(ruleset);
            throw np4_print_error(err);
        }

        //// tab_update_enc_L4
        // 1. Create default rule
        err = np4_rule_create(&rule, ruleset, "tab_update_enc_L4");
        if(err) {
            np4_ruleset_free(ruleset);
            throw np4_print_error(err);
        }
        err = np4_rule_mark_default(rule);
        if(err) {
            np4_ruleset_free(ruleset);
            throw np4_print_error(err);
        }
        // 2. Set action of the rule
        err = np4_rule_set_action(rule,"update_enc_L4");
        if(err) {
            np4_ruleset_free(ruleset);
            throw np4_print_error(err);
        }

        //// tab_update_L4
        // 1. Create default rule
        err = np4_rule_create(&rule, ruleset, "tab_update_L4");
        if(err) {
            np4_ruleset_free(ruleset);
            throw np4_print_error(err);
        }
        err = np4_rule_mark_default(rule);
        if(err) {
            np4_ruleset_free(ruleset);
            throw np4_print_error(err);
        }
        // 2. Set action of the rule
        err = np4_rule_set_action(rule,"update_L4");
        if(err) {
            np4_ruleset_free(ruleset);
            throw np4_print_error(err);
        }

        //// tab_terminate_gtp
        // 1. Create default rule
        err = np4_rule_create(&rule, ruleset, "tab_terminate_gtp");
        if(err) {
            np4_ruleset_free(ruleset);
            throw np4_print_error(err);
        }
        err = np4_rule_mark_default(rule);
        if(err) {
            np4_ruleset_free(ruleset);
            throw np4_print_error(err);
        }
        // 2. Set action of the rule
        err = np4_rule_set_action(rule,"terminate_gtp");
        if(err) {
            np4_ruleset_free(ruleset);
            throw np4_print_error(err);
        }
    }

    //// tab_send
    // 1. Create default rule
    err = np4_rule_create(&rule, ruleset, "tab_send");
    if(err) {
        np4_ruleset_free(ruleset);
        throw np4_print_error(err);
    }
    err = np4_rule_mark_default(rule);
    if(err) {
        np4_ruleset_free(ruleset);
        throw np4_print_error(err);
    }
    // 2. Set action of the rule
    err = np4_rule_set_action(rule,"send_to_port");
    if(err) {
        np4_ruleset_free(ruleset);
        throw np4_print_error(err);
    }
    uint8_t port[1] = { 1 };
    err = np4_rule_add_action_parameter(rule, "port", port, 1);
    if(err) {
        np4_ruleset_free(ruleset);
        throw np4_print_error(err);
    }

    // Insert Netcope P4 ruleset to hadrware
    err = np4_core_insert_ruleset(*np4, 0, ruleset);
    if(err) {
        np4_ruleset_free(ruleset);
        throw np4_print_error(err);
    }

    // Free ruleset
    np4_ruleset_free(ruleset);

    // Enable Netcope P4
    err = np4_core_enable(*np4, 0);
    if(err)
        throw np4_print_error(err);
}

/**
 * \brief Program main function.
 * @param argc Number of arguments.
 * @param argv Arguments themself.
 * @return Zero on success, error code otherwise.
 */
int main(int argc, char *argv[]) {
    int exit_code = EXIT_SUCCESS;
    // Netcope P4 datatype
    np4_t* np4 = NULL;

    try {
        // Parse program command line arguments
        arguments args(argc, argv);
        // If help is requested to display, don't continue further
        if(args.help)
            arguments::usage();
        else {
            // Prepare Netcope P4
            np4_preparation(args, &np4);

            // Run processing
            np4_processing(np4, args);
        }
    } catch(std::exception &e) {
        std::cerr << __progname << ": " << e.what() << std::endl;
        exit_code = EXIT_FAILURE;
    } catch(np4_error_t &e) {
        exit_code = EXIT_FAILURE;
    }

    if(np4!=NULL)
        np4_exit(&np4);
    return exit_code;
}
