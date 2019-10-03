//
// tables.p4: MAT definitions of Netcope P4 INT source & transit processing example.
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

// Actions =====================================================================
// -- process_int_source -------------------------------------------------------
action int_source(max_hop, ins_cnt, ins_map) {
    // insert INT shim header
    add_header(int_shim);
    // int_type: Hop-by-hop type (1) , destination type (2)
    modify_field(int_shim.int_type,1);
    modify_field(int_shim.len,INT_HEADER_LEN_WORD);

    // insert INT header
    add_header(int_header);
    modify_field(int_header.ver,0);
    modify_field(int_header.rep,0);
    modify_field(int_header.c,0);
    modify_field(int_header.e,0);
    modify_field(int_header.rsvd1,0);
    modify_field(int_header.ins_cnt,ins_cnt);
    modify_field(int_header.max_hop_count,max_hop);
    modify_field(int_header.total_hop_count,0);
    modify_field(int_header.instruction_map,ins_map);


    // insert INT tail header
    add_header(int_tail);
    modify_field(int_tail.next_proto,ipv4.protocol);
    modify_field(int_tail.dest_port,md_netcope.L4dst);
    modify_field(int_tail.dscp,ipv4.dscp);

    // add the header len (8 bytes) to total len
    add_to_field(ipv4.totalLen,16);
    add_to_field(udp.len,16);
}

action int_source_dscp(max_hop, ins_cnt, ins_map) {
    int_source(max_hop, ins_cnt, ins_map);
    modify_field(ipv4.dscp,INT_DSCP);
}

// -- process_set_source_sink --------------------------------------------------
action int_set_source () {
    modify_field(int_meta.source,1);
}

action int_set_sink () {
    modify_field(int_meta.sink,1);
}

// -- process_int_transit ------------------------------------------------------
action int_update_total_hop_cnt() {
    add_to_field(int_header.total_hop_count,1);
}

action int_transit(switch_id) {
    modify_field(int_meta.switch_id,switch_id);
    modify_field(int_meta.insert_byte_cnt,int_header.ins_cnt);
    shift_left(int_meta.insert_byte_cnt,int_meta.insert_byte_cnt,2);
}

action int_set_header_0() { //switch_id
    add_header(int_switch_id_0);
    modify_field(int_switch_id_0.switch_id,int_meta.switch_id);
}

action int_set_header_1() { //port_ids
    add_header(int_port_ids_0);
    modify_field(int_port_ids_0.ingress_port_id,standard_metadata.ingress_port);
    modify_field(int_port_ids_0.egress_port_id,standard_metadata.egress_port);
}

action int_set_header_2() { //hop_latency
    add_header(int_hop_latency_0);
    modify_field(int_hop_latency_0.hop_latency,CONST_HOP_LATENCY);
}
action int_set_header_3() { //q_occupancy
    // TODO: Support egress queue ID
    add_header(int_q_occupancy_0);
    modify_field(int_q_occupancy_0.q_id,0);
    // (bit<8>) standard_metadata.egress_qid;
    modify_field(int_q_occupancy_0.q_occupancy,CONST_Q_OCCUPANCY);
}
action int_set_header_4() { //ingress_tstamp
    add_header(int_ingress_tstamp_0);
    modify_field(int_ingress_tstamp_0.ingress_tstamp,intrinsic_metadata.ingress_timestamp);
}
action int_set_header_5() { //egress_timestamp
    add_header(int_egress_tstamp_0);
    modify_field(int_egress_tstamp_0.egress_tstamp,intrinsic_metadata.ingress_timestamp);
    add_to_field(int_egress_tstamp_0.egress_tstamp,CONST_HOP_LATENCY);
}
action int_set_header_6() { //q_congestion
    // TODO: implement queue congestion support in BMv2
    // TODO: update egress queue ID
    add_header(int_q_congestion_0);
    modify_field(int_q_congestion_0.q_id,0);
    // (bit<8>) standard_metadata.egress_qid;
    modify_field(int_q_congestion_0.q_congestion,0);
    // (bit<24>) queueing_metadata.deq_congestion;
}
action int_set_header_7() { //egress_port_tx_utilization
    // TODO: implement tx utilization support in BMv2
    add_header(int_egress_port_tx_util_0);
    modify_field(int_egress_port_tx_util_0.egress_port_tx_util,0);
    // (bit<32>) queueing_metadata.tx_utilization;
}

/* action function for bits 0-3 combinations, 0 is msb, 3 is lsb */
/* Each bit set indicates that corresponding INT header should be added */
action int_set_header_0003_i0() {
    no_op();
}
action int_set_header_0003_i1() {
    int_set_header_3();
}
action int_set_header_0003_i2() {
    int_set_header_2();
}
action int_set_header_0003_i3() {
    int_set_header_3();
    int_set_header_2();
}
action int_set_header_0003_i4() {
    int_set_header_1();
}
action int_set_header_0003_i5() {
    int_set_header_3();
    int_set_header_1();
}
action int_set_header_0003_i6() {
    int_set_header_2();
    int_set_header_1();
}
action int_set_header_0003_i7() {
    int_set_header_3();
    int_set_header_2();
    int_set_header_1();
}
action int_set_header_0003_i8() {
    int_set_header_0();
}
action int_set_header_0003_i9() {
    int_set_header_3();
    int_set_header_0();
}
action int_set_header_0003_i10() {
    int_set_header_2();
    int_set_header_0();
}
action int_set_header_0003_i11() {
    int_set_header_3();
    int_set_header_2();
    int_set_header_0();
}
action int_set_header_0003_i12() {
    int_set_header_1();
    int_set_header_0();
}
action int_set_header_0003_i13() {
    int_set_header_3();
    int_set_header_1();
    int_set_header_0();
}
action int_set_header_0003_i14() {
    int_set_header_2();
    int_set_header_1();
    int_set_header_0();
}
action int_set_header_0003_i15() {
    int_set_header_3();
    int_set_header_2();
    int_set_header_1();
    int_set_header_0();
}

/* action function for bits 4-7 combinations, 4 is msb, 7 is lsb */
action int_set_header_0407_i0() {
    no_op();
}
action int_set_header_0407_i1() {
    int_set_header_7();
}
action int_set_header_0407_i2() {
    int_set_header_6();
}
action int_set_header_0407_i3() {
    int_set_header_7();
    int_set_header_6();
}
action int_set_header_0407_i4() {
    int_set_header_5();
}
action int_set_header_0407_i5() {
    int_set_header_7();
    int_set_header_5();
}
action int_set_header_0407_i6() {
    int_set_header_6();
    int_set_header_5();
}
action int_set_header_0407_i7() {
    int_set_header_7();
    int_set_header_6();
    int_set_header_5();
}
action int_set_header_0407_i8() {
    int_set_header_4();
}
action int_set_header_0407_i9() {
    int_set_header_7();
    int_set_header_4();
}
action int_set_header_0407_i10() {
    int_set_header_6();
    int_set_header_4();
}
action int_set_header_0407_i11() {
    int_set_header_7();
    int_set_header_6();
    int_set_header_4();
}
action int_set_header_0407_i12() {
    int_set_header_5();
    int_set_header_4();
}
action int_set_header_0407_i13() {
    int_set_header_7();
    int_set_header_5();
    int_set_header_4();
}
action int_set_header_0407_i14() {
    int_set_header_6();
    int_set_header_5();
    int_set_header_4();
}
action int_set_header_0407_i15() {
    int_set_header_7();
    int_set_header_6();
    int_set_header_5();
    int_set_header_4();
}

//-- process_int_outer_encap ---------------------------------------------------
action int_update_ipv4_ac() {
    add_to_field(ipv4.totalLen,int_meta.insert_byte_cnt);
}
action int_update_udp_ac() {
    add_to_field(udp.len,int_meta.insert_byte_cnt);
}
action int_update_shim_ac() {
    add_to_field(int_shim.len,int_header.ins_cnt);
}

// -- general ------------------------------------------------------------------
// Drop the packet
action drop_packet() {
    drop();
}

// Do nothing
action permit() {
    no_op();
}

action send_to_cpu() {
     modify_field(standard_metadata.egress_port,CPU_PORT);
}

action send_to_eth() {
     modify_field(standard_metadata.egress_port,ETH_PORT);
}

action send_to_port(port) {
    modify_field(standard_metadata.egress_port,port);
}

// Add GTP
// Subaction for adding actual GTP header
action add_gtp() {
    add_header(gtp);
    modify_field(gtp.version,1);
    modify_field(gtp.protType,0);
    modify_field(gtp.reserved,0);
    modify_field(gtp.flags,0);
    modify_field(gtp.messageType,0);
    modify_field(gtp.messageLen,0);
    modify_field(gtp.teid,0);
}

// Subroutin that sets values of new outer headers
action add_gtp_set_new_outer(srcAddr,dstAddr) {
    modify_field(ipv4.protocol,PROTOCOL_UDP);
    modify_field(ipv4.version,4);
    modify_field(ipv4.ihl,5);
    modify_field(ipv4.dscp,0);
    modify_field(ipv4.ecn,0);
    // Increase length
    add_to_field(ipv4.totalLen,GTP_ENC_SIZE);
    modify_field(ipv4.id,0);
    modify_field(ipv4.flags,0);
    modify_field(ipv4.fragOffset,0);
    modify_field(ipv4.ttl,64);
    modify_field(ipv4.hdrChecksum,0);
    modify_field(ipv4.srcAddr,srcAddr);
    modify_field(ipv4.dstAddr,dstAddr);

    // Possibly add UDP (there might not have been one previously)
    add_header(udp);
    modify_field(udp.dstPort,GTPV1_PORT_VALUE);
    modify_field(udp.srcPort,GTPV1_PORT_VALUE);
    // Increase length
    add_to_field(udp.len,GTP_ENC_SIZE);
    modify_field(udp.csum,0);
}

// Subaction that adds and copies encapsulated IPv4
action add_gtp_add_ipv4() {
    add_header(enc_ipv4);
    modify_field(enc_ipv4.version,ipv4.version);
    modify_field(enc_ipv4.ihl,ipv4.ihl);
    modify_field(enc_ipv4.dscp,ipv4.dscp);
    modify_field(enc_ipv4.ecn,ipv4.ecn);
    modify_field(enc_ipv4.totalLen,ipv4.totalLen);
    modify_field(enc_ipv4.id,ipv4.id);
    modify_field(enc_ipv4.flags,ipv4.flags);
    modify_field(enc_ipv4.fragOffset,ipv4.fragOffset);
    modify_field(enc_ipv4.ttl,ipv4.ttl);
    modify_field(enc_ipv4.protocol,ipv4.protocol);
    modify_field(enc_ipv4.hdrChecksum,ipv4.hdrChecksum);
    modify_field(enc_ipv4.srcAddr,ipv4.srcAddr);
    modify_field(enc_ipv4.dstAddr,ipv4.dstAddr);
}

// Action for adding GTP to TCP packets
action add_gtp_to_tcp(srcAddr,dstAddr) {
    add_gtp();
    add_gtp_add_ipv4();
    // Prepare UDP length
    modify_field(udp.len,0);
    add_gtp_set_new_outer(srcAddr,dstAddr);
    // Modify UDP length
    add_to_field(udp.len,enc_ipv4.totalLen);
    subtract_from_field(udp.len,IPV4_HEADER_SIZE);
}

// Action for adding GTP to UDP packets
action add_gtp_to_udp(srcAddr,dstAddr) {
    add_gtp();
    add_gtp_add_ipv4();

    // Add and copy encapsulated UDP
    add_header(enc_udp);
    modify_field(enc_udp.srcPort,udp.srcPort);
    modify_field(enc_udp.dstPort,udp.dstPort);
    modify_field(enc_udp.len,udp.len);
    modify_field(enc_udp.csum,udp.csum);

    add_gtp_set_new_outer(srcAddr,dstAddr);
}

// Tables ======================================================================
// -- process_int_source -------------------------------------------------------
table tb_int_source {
    reads {
        ipv4.srcAddr: ternary;
        ipv4.dstAddr: ternary;
        md_netcope.L4src: ternary;
        md_netcope.L4dst: ternary;
    }
    actions {
        int_source_dscp;
    }
    size : 127;
}

// -- process_set_source_sink --------------------------------------------------
table tb_set_source {
    reads {
        standard_metadata.ingress_port: exact;
    }
    actions {
        int_set_source;
    }
    size : 255;
}

table tb_set_sink {
    reads {
        standard_metadata.egress_port: exact;
    }
    actions {
        int_set_sink;
    }
    size : 255;
}

// -- process_int_transit ------------------------------------------------------
table tb_int_insert {
    actions {
        int_transit;
    }
}

/* Table to process instruction bits 0-3 */
table tb_int_inst_0003 {
    reads {
        int_header.instruction_map : ternary;
    }
    actions {
        int_set_header_0003_i0;
        int_set_header_0003_i1;
        //int_set_header_0003_i2;
        //int_set_header_0003_i3;
        int_set_header_0003_i4;
        int_set_header_0003_i5;
        //int_set_header_0003_i6;
        //int_set_header_0003_i7;
        int_set_header_0003_i8;
        int_set_header_0003_i9;
        //int_set_header_0003_i10;
        //int_set_header_0003_i11;
        int_set_header_0003_i12;
        int_set_header_0003_i13;
        //int_set_header_0003_i14;
        //int_set_header_0003_i15;
    }
    size : 16;
}

/* Table to process instruction bits 4-7 */
table tb_int_inst_0407 {
    reads {
        int_header.instruction_map : ternary;
    }
    actions {
        int_set_header_0407_i0;
        //int_set_header_0407_i1;
        //int_set_header_0407_i2;
        //int_set_header_0407_i3;
        int_set_header_0407_i4;
        //int_set_header_0407_i5;
        //int_set_header_0407_i6;
        //int_set_header_0407_i7;
        int_set_header_0407_i8;
        //int_set_header_0407_i9;
        //int_set_header_0407_i10;
        //int_set_header_0407_i11;
        int_set_header_0407_i12;
        //int_set_header_0407_i13;
        //int_set_header_0407_i14;
        //int_set_header_0407_i15;
    }
    size : 16;
}

//-- process_int_outer_encap ---------------------------------------------------
table int_update_ipv4 {
    actions {
        int_update_ipv4_ac;
    }
}
table int_update_udp {
    actions {
        int_update_udp_ac;
    }
}
table int_update_shim {
    actions {
        int_update_shim_ac;
    }
}


// -- general ------------------------------------------------------------------
// Choose where to send
table tab_set_egress {
    reads {
        ethernet.dstAddr : ternary;
    }
    actions {
        permit;
        send_to_cpu;
        send_to_eth;
        send_to_port;
    }
    size : 31;
}

table tab_add_gtp_to_tcp {
    actions {
        add_gtp_to_tcp;
        permit;
    }
}

table tab_add_gtp_to_udp {
    actions {
        add_gtp_to_udp;
        permit;
    }
}
