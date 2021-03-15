  /*
 * Copyright 2020 PSNC
 *
 * Author: Damian Parniewicz
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


const bit<48> COLLECTOR_MAC = 0xf661c06a1421; 
const bit<32> COLLECTOR_IP = 0x0a0000fe;
const bit<48> DP_MAC =  0xf661c06a0001;
const bit<32> INT_REPORT_MIRROR_SESSION_ID = 1;   // mirror session specyfing egress_port for cloned INT report packets, defined by switch CLI command   

#ifdef BMV2

control Int_sink_config(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {

#elif TOFINO

control Int_sink_config(inout headers hdr, inout metadata meta, inout ingress_intrinsic_metadata_for_tm_t standard_metadata) {

#endif
    
    action configure_sink(bit<9> sink_reporting_port) {
        meta.int_metadata.remove_int = 1w1;   // indicate that INT headers must be removed in egress
        meta.int_metadata.sink_reporting_port = sink_reporting_port; 
        clone3<metadata>(CloneType.I2E, INT_REPORT_MIRROR_SESSION_ID, meta);
    }
    
   //table used to activate INT sink for particular egress port of the switch
    table tb_int_sink {
        actions = {
            configure_sink;
        }
        key = {
            #ifdef BMV2
            standard_metadata.egress_spec: exact;
            #elif TOFINO
            standard_metadata.ucast_egress_port: exact;
            #endif
        }
        size = 255;
    }
    
    apply {
       // INT sink must process only INT packets
        if (!hdr.int_header.isValid())
            return;
        
        tb_int_sink.apply();
    }
}


#ifdef BMV2

control Int_sink(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {

#elif TOFINO

control Int_sink(inout headers hdr, inout metadata meta, inout ingress_intrinsic_metadata_for_tm_t standard_metadata) {

#endif
    
    action remove_sink_header() {
         // restore original headers
        hdr.ipv4.dscp = hdr.int_tail.dscp;
        hdr.udp.dstPort = hdr.int_tail.dest_port;
        bit<16> len_bytes = ((bit<16>)hdr.int_shim.len) << 2;
        hdr.ipv4.totalLen = hdr.ipv4.totalLen - len_bytes;
        if (hdr.udp.isValid()) {
            hdr.udp.len = hdr.udp.len - len_bytes;
        }

        // remove INT data added in INT sink
        hdr.int_switch_id.setInvalid();
        hdr.int_port_ids.setInvalid();
        hdr.int_ingress_tstamp.setInvalid();
        hdr.int_egress_tstamp.setInvalid();
        hdr.int_hop_latency.setInvalid();
        hdr.int_q_congestion.setInvalid();
        hdr.int_q_occupancy.setInvalid();
        hdr.int_egress_port_tx_util.setInvalid();
        
        // remove int data
        hdr.int_shim.setInvalid();
        hdr.int_header.setInvalid();
        hdr.int_data.setInvalid();
        hdr.int_tail.setInvalid();
    }
    
    
    action send_report(bit<48> dp_mac, bit<48> collector_mac, bit<32> collector_ip)
    {
        // frame to INT collector requires proper MAC and IP addresses
        hdr.ethernet.srcAddr = dp_mac;
        hdr.ethernet.dstAddr = collector_mac;
        hdr.ipv4.dstAddr = collector_ip;
    }
    
    table tb_int_reporting {
        actions = {
            send_report;
        }
    }
    
    apply {
    
        // INT sink must process only INT packets
        if (!hdr.int_header.isValid())
            return;
        
        if (standard_metadata.instance_type == PKT_INSTANCE_TYPE_NORMAL && meta.int_metadata.remove_int == 1) {
            remove_sink_header();
        }
        if (standard_metadata.instance_type == PKT_INSTANCE_TYPE_INGRESS_CLONE) {
            
            // prepare INT report
   
            // send frame to INT collector
            tb_int_reporting.apply();
            
            //hdr.ethernet.srcAddr = DP_MAC;
            //hdr.ethernet.dstAddr = COLLECTOR_MAC;
            //hdr.ipv4.dstAddr = COLLECTOR_IP;
            
            // TODO
        }

    }
}