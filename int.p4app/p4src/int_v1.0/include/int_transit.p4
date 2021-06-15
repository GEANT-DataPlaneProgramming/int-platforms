/*
 * Copyright 2020-2021 PSNC, FBK
 *
 * Author: Damian Parniewicz, Damu Ding
 *
 * Created in the GN4-3 project.
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
#ifdef BMV2
register<bit<64>> (1) start_timestamp;
#endif

#ifdef BMV2

control Int_transit(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {

#elif TOFINO

    control Int_transit(inout headers hdr, inout metadata meta, in egress_intrinsic_metadata_t standard_metadata, in egress_intrinsic_metadata_from_parser_t imp) {

#endif

        // Configure parameters of INT transit node:
        // switch_id which is used within INT node metadata
        // l3_mtu is curently not used but should allow to detect condition if adding new INT metadata will exceed allowed MTU packet size

        action configure_transit(bit<32> switch_id, bit<16> l3_mtu) {
            meta.int_metadata.switch_id = switch_id;
            meta.int_metadata.insert_byte_cnt = 0;
            meta.int_metadata.int_hdr_word_len = 0;
            meta.layer34_metadata.l3_mtu = l3_mtu;
        }

        // Table used to configure a switch as a INT transit
        // If INT transit configured then all packets with INT header will be precessed by INT transit logic
        table tb_int_transit {
            actions = {
                configure_transit;
            }

            size = 512;
        }


        action int_set_header_0() {
            hdr.int_switch_id.setValid();
            hdr.int_switch_id.switch_id = meta.int_metadata.switch_id;
        }
        action int_set_header_1() {
            hdr.int_port_ids.setValid();
            //hdr.int_port_ids.ingress_port_id = (bit<16>)standard_metadata.ingress_port;
            hdr.int_port_ids.ingress_port_id = meta.int_metadata.ingress_port;
            #ifdef BMV2
            hdr.int_port_ids.egress_port_id = (bit<16>)standard_metadata.egress_port;
            #elif TOFINO

            hdr.int_port_ids.egress_port_id = (bit<16>)standard_metadata.egress_port;
            #endif
        }
        action int_set_header_2() {
            hdr.int_hop_latency.setValid();
            #ifdef BMV2
            hdr.int_hop_latency.hop_latency = (bit<32>)(standard_metadata.egress_global_timestamp - standard_metadata.ingress_global_timestamp);
            #elif TOFINO
            hdr.int_hop_latency.hop_latency = (bit<32>)(imp.global_tstamp - meta.int_metadata.ingress_tstamp); 
            #endif
        }
        action int_set_header_3() {
            hdr.int_q_occupancy.setValid();
            hdr.int_q_occupancy.q_id = 0; // qid not defined in v1model
            #ifdef BMV2
            hdr.int_q_occupancy.q_occupancy = (bit<24>)standard_metadata.enq_qdepth;
            #elif TOFINO
            //DAMU: Only valid in egress pipeline
            hdr.int_q_occupancy.q_occupancy = (bit<24>)standard_metadata.enq_qdepth;
            /*hdr.int_q_occupancy.q_occupancy = 24w2;*/
            #endif
        }
        action int_set_header_4() {
            hdr.int_ingress_tstamp.setValid();
#ifdef BMV2
            start_timestamp.read(hdr.int_ingress_tstamp.ingress_tstamp, 0);
            //bit<64> _timestamp = (bit<64>)standard_metadata.ingress_global_timestamp;   
            bit<64> _timestamp = (bit<64>)meta.int_metadata.ingress_tstamp;  
            hdr.int_ingress_tstamp.ingress_tstamp = hdr.int_ingress_tstamp.ingress_tstamp + 1000 * _timestamp;
#elif TOFINO
// Not OK
           /* hdr.int_ingress_tstamp.ingress_tstamp[63:32] = meta.h_time;*/
            /*hdr.int_ingress_tstamp.ingress_tstamp[31:16] = meta.l_time[31:16];*/
            /*hdr.int_ingress_tstamp.ingress_tstamp[15:0] = imp.global_tstamp[15:0];*/
        hdr.int_ingress_tstamp.ingress_tstamp = (bit<64>)meta.int_metadata.ingress_tstamp;
#endif
        }
        action int_set_header_5() {
            hdr.int_egress_tstamp.setValid();
#ifdef BMV2
            start_timestamp.read(hdr.int_egress_tstamp.egress_tstamp, 0);
            bit<64> _timestamp = (bit<64>)standard_metadata.egress_global_timestamp;
            hdr.int_egress_tstamp.egress_tstamp = hdr.int_egress_tstamp.egress_tstamp + 1000 * _timestamp;
#elif TOFINO
// Not OK
            /*hdr.int_egress_tstamp.egress_tstamp[63:32] = meta.h_time;*/
            /*hdr.int_egress_tstamp.egress_tstamp[31:16] = meta.l_time[31:16];*/
            /*hdr.int_egress_tstamp.egress_tstamp[15:0] = imp.global_tstamp[15:0];*/
            hdr.int_egress_tstamp.egress_tstamp = (bit<64>)imp.global_tstamp;
#endif
        }
        action int_set_header_6() {
            hdr.int_level2_port_ids.setValid();
            // no such metadata in v1model
            hdr.int_level2_port_ids.ingress_port_id = 0;
            hdr.int_level2_port_ids.egress_port_id = 0;
        }
        action int_set_header_7() {
            hdr.int_egress_port_tx_util.setValid();
            // no such metadata in v1model
            hdr.int_egress_port_tx_util.egress_port_tx_util = 0;
        }

        action add_1() {
            meta.int_metadata.int_hdr_word_len = meta.int_metadata.int_hdr_word_len + 1;
            meta.int_metadata.insert_byte_cnt = meta.int_metadata.insert_byte_cnt + 4;
        }

        action add_2() {
            meta.int_metadata.int_hdr_word_len = meta.int_metadata.int_hdr_word_len + 2;
            meta.int_metadata.insert_byte_cnt = meta.int_metadata.insert_byte_cnt + 8;
        }

        action add_3() {
            meta.int_metadata.int_hdr_word_len = meta.int_metadata.int_hdr_word_len + 3;
            meta.int_metadata.insert_byte_cnt = meta.int_metadata.insert_byte_cnt + 12;
        }

        action add_4() {
            meta.int_metadata.int_hdr_word_len = meta.int_metadata.int_hdr_word_len + 4;
            meta.int_metadata.insert_byte_cnt = meta.int_metadata.insert_byte_cnt + 16;
        }


        action add_5() {
            meta.int_metadata.int_hdr_word_len = meta.int_metadata.int_hdr_word_len + 5;
            meta.int_metadata.insert_byte_cnt = meta.int_metadata.insert_byte_cnt + 20;
        }

        action add_6() {
            meta.int_metadata.int_hdr_word_len = meta.int_metadata.int_hdr_word_len + 6;
            meta.int_metadata.insert_byte_cnt = meta.int_metadata.insert_byte_cnt + 24;
        }

        // hdr.int_switch_id     0
        // hdr.int_port_ids       1
        // hdr.int_hop_latency    2
        // hdr.int_q_occupancy    3
        // hdr.int_ingress_tstamp  4
        // hdr.int_egress_tstamp   5
        // hdr.int_level2_port_ids   6
        // hdr.int_egress_port_tx_util   7

        action int_set_header_0003_i0() {
            ;
        }
        action int_set_header_0003_i1() {
            int_set_header_3();
            add_1();
        }
        action int_set_header_0003_i2() {
            int_set_header_2();
            add_1();
        }
        action int_set_header_0003_i3() {
            int_set_header_5();
            int_set_header_2();
            add_3();
        }
        action int_set_header_0003_i4() {
            int_set_header_1();
            add_1();
        }
        action int_set_header_0003_i5() {
            int_set_header_3();
            int_set_header_1();
            add_2();
        }
        action int_set_header_0003_i6() {
            int_set_header_2();
            int_set_header_1();
            add_2();
        }
        action int_set_header_0003_i7() {
            int_set_header_3();
            int_set_header_2();
            int_set_header_1();
            add_3();
        }
        action int_set_header_0003_i8() {
            int_set_header_0();
            add_1();
        }
        action int_set_header_0003_i9() {
            int_set_header_3();
            int_set_header_0();
            add_2();
        }
        action int_set_header_0003_i10() {
            int_set_header_2();
            int_set_header_0();
            add_2();
        }
        action int_set_header_0003_i11() {
            int_set_header_3();
            int_set_header_2();
            int_set_header_0();
            add_3();
        }
        action int_set_header_0003_i12() {
            int_set_header_1();
            int_set_header_0();
            add_2();
        }
        action int_set_header_0003_i13() {
            int_set_header_3();
            int_set_header_1();
            int_set_header_0();
            add_3();
        }
        action int_set_header_0003_i14() {
            int_set_header_2();
            int_set_header_1();
            int_set_header_0();
            add_3();
        }
        action int_set_header_0003_i15() {
            int_set_header_3();
            int_set_header_2();
            int_set_header_1();
            int_set_header_0();
            add_4();
        }
        action int_set_header_0407_i0() {
            ;
        }

        action int_set_header_0407_i1() {
            int_set_header_7();
            add_1();
        }
        action int_set_header_0407_i2() {
            int_set_header_6();
            add_1();
        }
        action int_set_header_0407_i3() {
            int_set_header_7();
            int_set_header_6();
            add_2();

        }
        action int_set_header_0407_i4() {
            int_set_header_5();
            add_2();
        }
        action int_set_header_0407_i5() {
            int_set_header_7();
            int_set_header_5();
            add_3();
        }
        action int_set_header_0407_i6() {
            int_set_header_6();
            int_set_header_5();
            add_3();
        }
        action int_set_header_0407_i7() {
            int_set_header_7();
            int_set_header_6();
            int_set_header_5();
            add_4();
        }
        action int_set_header_0407_i8() {
            int_set_header_4();
            add_2();
        }
        action int_set_header_0407_i9() {
            int_set_header_7();
            int_set_header_4();
            add_3();
        }
        action int_set_header_0407_i10() {
            int_set_header_6();
            int_set_header_4();
            add_3();
        }
        action int_set_header_0407_i11() {
            int_set_header_7();
            int_set_header_6();
            int_set_header_4();
            add_4();
        }
        action int_set_header_0407_i12() {
            int_set_header_5();
            int_set_header_4();
            add_4();
        }
        action int_set_header_0407_i13() {
            int_set_header_7();
            int_set_header_5();
            int_set_header_4();
            add_5();
        }
        action int_set_header_0407_i14() {
            int_set_header_6();
            int_set_header_5();
            int_set_header_4();
            add_5();
        }
        action int_set_header_0407_i15() {
            int_set_header_7();
            int_set_header_6();
            int_set_header_5();
            int_set_header_4();
            add_6();
        }


        table tb_int_inst_0003 {
            actions = {
                int_set_header_0003_i0;
                int_set_header_0003_i1;
                int_set_header_0003_i2;
                int_set_header_0003_i3;
                int_set_header_0003_i4;
                int_set_header_0003_i5;
                int_set_header_0003_i6;
                int_set_header_0003_i7;
                int_set_header_0003_i8;
                int_set_header_0003_i9;
                int_set_header_0003_i10;
                int_set_header_0003_i11;
                int_set_header_0003_i12;
                int_set_header_0003_i13;
                int_set_header_0003_i14;
                int_set_header_0003_i15;
            }
            key = {
                hdr.int_header.instruction_mask: ternary;
            }
            const entries = {
                0x00 &&& 0xF0 : int_set_header_0003_i0();
                0x10 &&& 0xF0 : int_set_header_0003_i1();
                0x20 &&& 0xF0 : int_set_header_0003_i2();
                0x30 &&& 0xF0 : int_set_header_0003_i3();
                0x40 &&& 0xF0 : int_set_header_0003_i4();
                0x50 &&& 0xF0 : int_set_header_0003_i5();
                0x60 &&& 0xF0 : int_set_header_0003_i6();
                0x70 &&& 0xF0 : int_set_header_0003_i7();
                0x80 &&& 0xF0 : int_set_header_0003_i8();
                0x90 &&& 0xF0 : int_set_header_0003_i9();
                0xA0 &&& 0xF0 : int_set_header_0003_i10();
                0xB0 &&& 0xF0 : int_set_header_0003_i11();
                0xC0 &&& 0xF0 : int_set_header_0003_i12();
                0xD0 &&& 0xF0 : int_set_header_0003_i13();
                0xE0 &&& 0xF0 : int_set_header_0003_i14();
                0xF0 &&& 0xF0 : int_set_header_0003_i15();
            }
            size = 512;
        }

        table tb_int_inst_0407 {
            actions = {
                int_set_header_0407_i0;
                int_set_header_0407_i1;
                int_set_header_0407_i2;
                int_set_header_0407_i3;
                int_set_header_0407_i4;
                int_set_header_0407_i5;
                int_set_header_0407_i6;
                int_set_header_0407_i7;
                int_set_header_0407_i8;
                int_set_header_0407_i9;
                int_set_header_0407_i10;
                int_set_header_0407_i11;
                int_set_header_0407_i12;
                int_set_header_0407_i13;
                int_set_header_0407_i14;
                int_set_header_0407_i15;
            }
            key = {
                hdr.int_header.instruction_mask: ternary;
            }
            const entries = {
                0x00 &&& 0x0F : int_set_header_0407_i0();
                0x01 &&& 0x0F : int_set_header_0407_i1();
                0x02 &&& 0x0F : int_set_header_0407_i2();
                0x03 &&& 0x0F : int_set_header_0407_i3();
                0x04 &&& 0x0F : int_set_header_0407_i4();
                0x05 &&& 0x0F : int_set_header_0407_i5();
                0x06 &&& 0x0F : int_set_header_0407_i6();
                0x07 &&& 0x0F : int_set_header_0407_i7();
                0x08 &&& 0x0F : int_set_header_0407_i8();
                0x09 &&& 0x0F : int_set_header_0407_i9();
                0x0A &&& 0x0F : int_set_header_0407_i10();
                0x0B &&& 0x0F : int_set_header_0407_i11();
                0x0C &&& 0x0F : int_set_header_0407_i12();
                0x0D &&& 0x0F : int_set_header_0407_i13();
                0x0E &&& 0x0F : int_set_header_0407_i14();
                0x0F &&& 0x0F : int_set_header_0407_i15();
            }

            size = 512;
        }

        action int_hop_cnt_increment() {
            hdr.int_header.remaining_hop_cnt = hdr.int_header.remaining_hop_cnt - 1;
        }
        action int_hop_exceeded() {
            hdr.int_header.e = 1w1;
        }

        action int_update_ipv4_ac() {
            hdr.ipv4.totalLen = hdr.ipv4.totalLen + (bit<16>)meta.int_metadata.insert_byte_cnt;
        }
        action int_update_shim_ac() {
            hdr.int_shim.len = hdr.int_shim.len + (bit<8>)meta.int_metadata.int_hdr_word_len;
        }
        action int_update_udp_ac() {
            hdr.udp.len = hdr.udp.len + (bit<16>)meta.int_metadata.insert_byte_cnt;
        }

        apply {	

            // INT transit must process only INT packets
            if (!hdr.int_header.isValid())
                return;

            //TODO: check if hop-by-hop INT or destination INT

            // check if INT transit can add a new INT node metadata
            if (hdr.int_header.remaining_hop_cnt == 0 || hdr.int_header.e == 1) {
                int_hop_exceeded();
                return;
            }

            int_hop_cnt_increment();

            // add INT node metadata headers based on INT instruction_mask
            tb_int_transit.apply();
            tb_int_inst_0003.apply();
            tb_int_inst_0407.apply();

            //update length fields in IPv4, UDP and INT
            int_update_ipv4_ac();

            if (hdr.udp.isValid())
                int_update_udp_ac();

            if (hdr.int_shim.isValid()) 
                int_update_shim_ac();
        }
    }
