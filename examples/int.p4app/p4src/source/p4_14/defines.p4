//
// defines.p4: Constant definitions of Netcope P4 INT source & transit processing example.
// Copyright (C) 2018 Netcope Technologies, a.s.
// Author(s): Michal Kekely <kekely@netcope.com>
//

//
// This file is part of Netcope distribution (https://github.com/netcope).
// Copyright (c) 2018 Netcope Technologies, a.s.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3.
//
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
// General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.
//

#define INT_HEADER_LEN_WORD 4
#define CPU_PORT            128
#define ETH_PORT            0

#define GTP_ENC_SIZE        36
#define IPV4_HEADER_SIZE    20

#define CONST_HOP_LATENCY   1
#define CONST_Q_OCCUPANCY   2

// Protocol numbers ============================================================
#define PROTOCOL_IPV4 		0x0800
#define PROTOCOL_IPV6 		0x86dd
#define PROTOCOL_TCP 		0x06
#define PROTOCOL_UDP 		0x11
#define GTPV1_PORT_VALUE    2152
#define GTPV1_PORT          GTPV1_PORT_VALUE mask 0x00FFFF
#define INT_DSCP_WDP        0x200000 mask 0x3F0000
#define INT_DSCP            0x20

// Select statements of INT stack ==============================================
// The select consists of:
// instruction count (5b), instruction bit map (16b), lenght (8b)
#define INT_SELECT_CONCAT           md_netcope.INTinscnt,md_netcope.INTinsmap,md_netcope.INTlen
// When choosing the next instruction we want to mask out length and IC
// and then only set the corresponding bit
#define MASK_SWITCH_ID              0x00800000
#define VAL_SWITCH_ID               MASK_SWITCH_ID
#define MASK_PORT_IDS               0x00400000
#define VAL_PORT_IDS                MASK_PORT_IDS
#define MASK_HOP_LATENCY            0x00200000
#define VAL_HOP_LATENCY             MASK_HOP_LATENCY
#define MASK_Q_OCCUPANCY            0x00100000
#define VAL_Q_OCCUPANCY             MASK_Q_OCCUPANCY
#define MASK_INGRESS_TSTAMP         0x00080000
#define VAL_INGRESS_TSTAMP          MASK_INGRESS_TSTAMP
#define MASK_EGRESS_TSTAMP          0x00040000
#define VAL_EGRESS_TSTAMP           MASK_EGRESS_TSTAMP
#define MASK_Q_CONGESTION           0x00020000
#define VAL_Q_CONGESTION            MASK_Q_CONGESTION
#define MASK_EGRESS_PORT_TX_UTIL    0x00010000
#define VAL_EGRESS_PORT_TX_UTIL     MASK_EGRESS_PORT_TX_UTIL
// For length set either only length bits or also IC bits
#define MLI                         0x1F0000FF
#define ML                          0x000000FF
// Expected INT lengths based on number of hops (and IC)
// 0 hops always mean length of 4
#define LEN_HOPS_0                  0x00000004 mask ML
// 1 hop means length of 4+(IC*1) - this means 5 for IC=1, 6 for IC=2 and so on up to 12 for IC=8
#define LEN_HOPS_1                  0x01000005 mask MLI, 0x02000006 mask MLI, 0x03000007 mask MLI, 0x04000008 mask MLI, 0x05000009 mask MLI, 0x0600000A mask MLI, 0x0700000B mask MLI, 0x0800000C mask MLI
// 2 hops mean length of 4+(IC*2) - this means 6 for IC=1, 8 for IC=2 and so on up to 20 for IC=8
#define LEN_HOPS_2                  0x01000006 mask MLI, 0x02000008 mask MLI, 0x0300000A mask MLI, 0x0400000C mask MLI, 0x0500000E mask MLI, 0x06000010 mask MLI, 0x07000012 mask MLI, 0x08000014 mask MLI
