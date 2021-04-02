/*
 * Copyright 2020 PSNC
 *
 * Author: Damian Parniewicz
 *
 * Created in the GN4-3 project.
 *
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

control Int_source(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {

#elif TOFINO

control Int_source(inout headers hdr, inout metadata meta, in ingress_intrinsic_metadata_t standard_metadata) {

#endif

    // Configure parameters of INT source node
    // max_hop - how many INT nodes can add their INT node metadata
    // hope_metadata_len - how INT metadata words are added by a single INT node
    // ins_cnt - how many INT headers must be added by a single INT node
    // ins_mask - instruction_mask defining which information (INT headers types) must added to the packet
    action configure_source(bit<8> max_hop, bit<5> hope_metadata_len, bit<5> ins_cnt, bit<16> ins_mask) {
        hdr.int_shim.setValid();
        hdr.int_shim.int_type = INT_TYPE_HOP_BY_HOP;
        hdr.int_shim.len = (bit<8>)INT_ALL_HEADER_LEN_BYTES>>2;
        
        hdr.int_header.setValid();
        hdr.int_header.ver = INT_VERSION;
        hdr.int_header.rep = 0;
        hdr.int_header.c = 0;
        hdr.int_header.e = 0;
        hdr.int_header.rsvd1 = 0;
        hdr.int_header.rsvd2 = 0;
        hdr.int_header.hop_metadata_len = hope_metadata_len;
        hdr.int_header.remaining_hop_cnt = max_hop;  //will be decreased immediately by 1 within transit process
        hdr.int_header.instruction_mask = ins_mask;
        
        hdr.int_shim.dscp = hdr.ipv4.dscp;
        
        hdr.ipv4.dscp = IPv4_DSCP_INT;   // indicates that INT header in the packet
        hdr.ipv4.totalLen = hdr.ipv4.totalLen + INT_ALL_HEADER_LEN_BYTES;  // adding size of INT headers
        
        hdr.udp.len = hdr.udp.len + INT_ALL_HEADER_LEN_BYTES;
    }
    
    // INT source must be configured per each flow which must be monitored using INT
    // Flow is defined by src IP, dst IP, src TCP/UDP port, dst TCP/UDP port 
    // When INT source configured for a flow then a node adds INT shim header and first INT node metadata headers
    table tb_int_source {
        actions = {
            configure_source;
        }
        #ifdef BMV2
        key = {
            hdr.ipv4.srcAddr     : ternary;
            hdr.ipv4.dstAddr     : ternary;
            meta.layer34_metadata.l4_src: ternary;
            meta.layer34_metadata.l4_dst: ternary;
        }
        #endif
        size = 127;
        //default_action =
        //    configure_source(4,4, 0x00cc);
    }


    action activate_source() {
        meta.int_metadata.source = 1w1;
    }
    
    // table used to active INT source for a ingress port of the switch
    table tb_activate_source {
        actions = {
            activate_source;
        }
        #ifdef BMV2
        key = {
            standard_metadata.ingress_port: exact;
        }
        #endif
        size = 255;
    }


    apply {
        #ifdef BMV2
        
        // in case of frame clone for the INT sink reporting
        // ingress timestamp is not available on Egress pipeline
        meta.int_metadata.ingress_tstamp = standard_metadata.ingress_global_timestamp;
        
        //check if packet appeard on ingress port with active INT source
        tb_activate_source.apply();
        
        if (meta.int_metadata.source == 1w1)      
        #endif
        //TODO: find TOFINO equivalent
            //apply INT source logic on INT monitored flow
            tb_int_source.apply();
    }
}