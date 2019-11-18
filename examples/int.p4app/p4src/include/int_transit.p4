control Int_transit(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {

    @name(".configure_transit") action configure_transit(bit<32> switch_id, bit<16> l3_mtu) {
        meta.int_metadata.switch_id = switch_id;
        meta.int_metadata.insert_byte_cnt = (bit<16>) hdr.int_header.hop_metadata_len << 2;
        meta.int_metadata.int_hdr_word_len = (bit<8>) hdr.int_header.hop_metadata_len;
        meta.layer34_metadata.l3_mtu = l3_mtu;
    }
    @name(".tb_int_transit") table tb_int_transit {
        actions = {
            configure_transit;
        }
    }

    @name(".int_set_header_0") action int_set_header_0() {
        hdr.int_switch_id.setValid();
        hdr.int_switch_id.switch_id = meta.int_metadata.switch_id;
    }
    @name(".int_set_header_1") action int_set_header_1() {
        hdr.int_port_ids.setValid();
        hdr.int_port_ids.ingress_port_id = (bit<16>)standard_metadata.ingress_port;
        hdr.int_port_ids.egress_port_id = (bit<16>)standard_metadata.egress_port;
    }
    @name(".int_set_header_3") action int_set_header_3() {
        hdr.int_q_occupancy.setValid();
        hdr.int_q_occupancy.q_id = 8w0;
        hdr.int_q_occupancy.q_occupancy = 24w2;
    }
    @name(".int_set_header_4") action int_set_header_4() {
        hdr.int_ingress_tstamp.setValid();
        hdr.int_ingress_tstamp.ingress_tstamp = (bit<32>)meta.intrinsic_metadata.ingress_timestamp;
    }
    @name(".int_set_header_5") action int_set_header_5() {
        hdr.int_egress_tstamp.setValid();
        hdr.int_egress_tstamp.egress_tstamp = (bit<32>)meta.intrinsic_metadata.ingress_timestamp;
        hdr.int_egress_tstamp.egress_tstamp = hdr.int_egress_tstamp.egress_tstamp + 32w1;
    }

    @name(".int_set_header_0003_i0") action int_set_header_0003_i0() {
        ;
    }
    @name(".int_set_header_0003_i1") action int_set_header_0003_i1() {
        int_set_header_3();
    }
    @name(".int_set_header_0003_i4") action int_set_header_0003_i4() {
        int_set_header_1();
    }
    @name(".int_set_header_0003_i5") action int_set_header_0003_i5() {
        int_set_header_3();
        int_set_header_1();
    }
    @name(".int_set_header_0003_i8") action int_set_header_0003_i8() {
        int_set_header_0();
    }
    @name(".int_set_header_0003_i9") action int_set_header_0003_i9() {
        int_set_header_3();
        int_set_header_0();
    }
    @name(".int_set_header_0003_i12") action int_set_header_0003_i12() {
        int_set_header_1();
        int_set_header_0();
    }
    @name(".int_set_header_0003_i13") action int_set_header_0003_i13() {
        int_set_header_3();
        int_set_header_1();
        int_set_header_0();
    }
    @name(".int_set_header_0407_i0") action int_set_header_0407_i0() {
        ;
    }
    @name(".int_set_header_0407_i4") action int_set_header_0407_i4() {
        int_set_header_5();
    }
    @name(".int_set_header_0407_i8") action int_set_header_0407_i8() {
        int_set_header_4();
    }
    @name(".int_set_header_0407_i12") action int_set_header_0407_i12() {
        int_set_header_5();
        int_set_header_4();
    }

    @name(".tb_int_inst_0003") table tb_int_inst_0003 {
        actions = {
            int_set_header_0003_i0;
            int_set_header_0003_i1;
            int_set_header_0003_i4;
            int_set_header_0003_i5;
            int_set_header_0003_i8;
            int_set_header_0003_i9;
            int_set_header_0003_i12;
            int_set_header_0003_i13;
        }
        key = {
            hdr.int_header.instruction_mask: ternary;
        }
        const entries = {
            0x00 &&& 0xF0 : int_set_header_0003_i0();
            0x10 &&& 0xF0 : int_set_header_0003_i1();
            0x40 &&& 0xF0 : int_set_header_0003_i4();
            0x50 &&& 0xF0 : int_set_header_0003_i5();
            0x80 &&& 0xF0 : int_set_header_0003_i8();
            0x90 &&& 0xF0 : int_set_header_0003_i9();
            0xC0 &&& 0xF0 : int_set_header_0003_i12();
            0xD0 &&& 0xF0 : int_set_header_0003_i13();
        }
        size = 16;
    }
    @name(".tb_int_inst_0407") table tb_int_inst_0407 {
        actions = {
            int_set_header_0407_i0;
            int_set_header_0407_i4;
            int_set_header_0407_i8;
            int_set_header_0407_i12;
        }
        key = {
            hdr.int_header.instruction_mask: ternary;
        }
        const entries = {
            0x00 &&& 0x0F : int_set_header_0407_i0();
            0x04 &&& 0x0F : int_set_header_0407_i4();
            0x08 &&& 0x0F : int_set_header_0407_i8();
            0x0C &&& 0x0F : int_set_header_0407_i12();
        }
        size = 16;
    }

    @name(".int_hop_cnt_decrement") action int_hop_cnt_decrement() {
        hdr.int_header.remaining_hop_cnt = hdr.int_header.remaining_hop_cnt - 1;
    }
    @name(".int_hop_exceeded") action int_hop_exceeded() {
        hdr.int_header.e = 1w1;
    }
    @name(".int_mtu_limit_hit") action int_mtu_limit_hit() {
        hdr.int_header.m = 1w1;
    }

    @name(".int_update_ipv4_ac") action int_update_ipv4_ac() {
        hdr.ipv4.totalLen = hdr.ipv4.totalLen + (bit<16>)meta.int_metadata.insert_byte_cnt;
    }
    @name(".int_update_shim_ac") action int_update_shim_ac() {
        hdr.int_shim.len = hdr.int_shim.len + (bit<8>)meta.int_metadata.int_hdr_word_len;
    }
    @name(".int_update_udp_ac") action int_update_udp_ac() {
        hdr.udp.len = hdr.udp.len + (bit<16>)meta.int_metadata.insert_byte_cnt;
    }

    apply {	
        
        if (!hdr.int_header.isValid())
            return;
        
        //TODO: check if hop-by-hop INT or destination INT
        
        if (hdr.int_header.remaining_hop_cnt == 0 || hdr.int_header.e == 1) {
            int_hop_exceeded();
            return;
        }
        
        if (hdr.ipv4.totalLen + meta.int_metadata.insert_byte_cnt > meta.layer34_metadata.l3_mtu)
            int_mtu_limit_hit();

        int_hop_cnt_decrement();

        tb_int_transit.apply();
        tb_int_inst_0003.apply();
        tb_int_inst_0407.apply();
        
        int_update_ipv4_ac();

        if (hdr.udp.isValid())
            int_update_udp_ac();

        if (hdr.int_shim.isValid()) 
            int_update_shim_ac();
    }
}