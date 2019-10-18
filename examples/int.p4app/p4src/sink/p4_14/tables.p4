//
// tables.p4: MAT definitions of Netcope P4 INT sink processing example.
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
// Remove the INT information
action act_remove_int() {
    // Remove all the int headers
    remove_header(int_shim);
    remove_header(int_tail);
    remove_header(int_header);
    remove_header(int_switch_id_0);
    remove_header(int_port_ids_0);
    //remove_header(int_hop_latency_0);
    remove_header(int_q_occupancy_0);
    remove_header(int_ingress_tstamp_0);
    //remove_header(int_egress_tstamp_0);
    //remove_header(int_q_congestion_0);
    //remove_header(int_egress_port_tx_util_0);
    remove_header(int_switch_id_1);
    remove_header(int_port_ids_1);
    //remove_header(int_hop_latency_1);
    remove_header(int_q_occupancy_1);
    remove_header(int_ingress_tstamp_1);
    //remove_header(int_egress_tstamp_1);
    //remove_header(int_q_congestion_1);
    //remove_header(int_egress_port_tx_util_1);
    remove_header(int_switch_id_2);
    remove_header(int_port_ids_2);
    //remove_header(int_hop_latency_2);
    remove_header(int_q_occupancy_2);
    remove_header(int_ingress_tstamp_2);
    //remove_header(int_egress_tstamp_2);
    //remove_header(int_q_congestion_2);
    //remove_header(int_egress_port_tx_util_2);
    remove_header(int_switch_id_3);
    remove_header(int_port_ids_3);
    //remove_header(int_hop_latency_3);
    remove_header(int_q_occupancy_3);
    remove_header(int_ingress_tstamp_3);
    //remove_header(int_egress_tstamp_3);
    //remove_header(int_q_congestion_3);
    //remove_header(int_egress_port_tx_util_3);
    //remove_header(int_switch_id_4);
    //remove_header(int_port_ids_4);
    ////remove_header(int_hop_latency_4);
    //remove_header(int_q_occupancy_4);
    //remove_header(int_ingress_tstamp_4);
    ////remove_header(int_egress_tstamp_4);
    ////remove_header(int_q_congestion_4);
    ////remove_header(int_egress_port_tx_util_4);
    remove_header(int_switch_id_5);
    remove_header(int_port_ids_5);
    //remove_header(int_hop_latency_5);
    remove_header(int_q_occupancy_5);
    remove_header(int_ingress_tstamp_5);
    //remove_header(int_egress_tstamp_5);
    //remove_header(int_q_congestion_5);
    //remove_header(int_egress_port_tx_util_5);
}

// Drop the packet
action drop_packet() {
    drop();
}

// Do nothing
action permit() {
    no_op();
}

action send_to_dma() {
     modify_field(standard_metadata.egress_port,128);
}

action send_to_eth() {
     modify_field(standard_metadata.egress_port,0);
}

action send_to_port(port) {
    modify_field(standard_metadata.egress_port,port);
}

action update_L4() {
    modify_field(ipv4.protocol,int_tail.next_proto);
    modify_field(ipv4.dscp,int_tail.dscp);
    modify_field(udp.dstPort,int_tail.dest_port);
    modify_field(tcp.dstPort,int_tail.dest_port);
    modify_field(md_netcope.L4proto,int_tail.next_proto);
    modify_field(md_netcope.L4dst,int_tail.dest_port);
    // Update lengths
    modify_field(internal_metadata.INTlenB,md_netcope.INTlen);
    add_to_field(internal_metadata.INTlenB,md_netcope.INTlen);
    add_to_field(internal_metadata.INTlenB,md_netcope.INTlen);
    add_to_field(internal_metadata.INTlenB,md_netcope.INTlen);
    subtract_from_field(ipv4.totalLen,internal_metadata.INTlenB);
    subtract_from_field(udp.len,internal_metadata.INTlenB);
    // Update checksums
    modify_field_with_hash_based_offset(ipv4.hdrChecksum,0,ipv4_csum,65536);
    modify_field(udp.csum,0);
    modify_field(tcp.csum,0);
}

action update_enc_L4() {
    modify_field(enc_ipv4.protocol,int_tail.next_proto);
    modify_field(enc_ipv4.dscp,int_tail.dscp);
    modify_field(enc_udp.dstPort,int_tail.dest_port);
    modify_field(tcp.dstPort,int_tail.dest_port);
    modify_field(md_netcope.L4proto,int_tail.next_proto);
    modify_field(md_netcope.L4dst,int_tail.dest_port);
    // Update lengths
    modify_field(internal_metadata.INTlenB,md_netcope.INTlen);
    add_to_field(internal_metadata.INTlenB,md_netcope.INTlen);
    add_to_field(internal_metadata.INTlenB,md_netcope.INTlen);
    add_to_field(internal_metadata.INTlenB,md_netcope.INTlen);
    subtract_from_field(ipv4.totalLen,internal_metadata.INTlenB);
    subtract_from_field(udp.len,internal_metadata.INTlenB);
    subtract_from_field(enc_ipv4.totalLen,internal_metadata.INTlenB);
    subtract_from_field(enc_udp.len,internal_metadata.INTlenB);
    // Update checksums
    modify_field_with_hash_based_offset(ipv4.hdrChecksum,0,ipv4_csum,65536);
    modify_field_with_hash_based_offset(enc_ipv4.hdrChecksum,0,enc_ipv4_csum,65536);
    modify_field(udp.csum,0);
    modify_field(tcp.csum,0);
    modify_field(enc_udp.csum,0);
}

action terminate_gtp() {
    remove_header(gtp);
    remove_header(udp);
    remove_header(ipv4);
}

// Tables ======================================================================
// Remove int
table tab_remove_int {
    // No reads statement, always run action
    actions {
        permit;
        act_remove_int;
        drop_packet;
    }
}

// Update L4
table tab_update_L4 {
    // No reads statement, always run action
    actions {
        permit;
        update_L4;
    }
}

// Update encapsulated L4
table tab_update_enc_L4 {
    // No reads statement, always run action
    actions {
        permit;
        update_enc_L4;
    }
}

// Choose where to send
table tab_send {
    // No reads statement, always run action
    actions {
        permit;
        send_to_dma;
        send_to_eth;
        send_to_port;
    }
}

// Unpack GTP
table tab_terminate_gtp {
    // No reads statement, always run default action
    actions {
        permit;
        terminate_gtp;
    }
}
