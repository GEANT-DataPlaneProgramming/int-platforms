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

/////////////////////////////////////////////////////////////////////////////////////////////////////////

/*#define BMV2 1*/
#define TOFINO 2

#include <core.p4>

#ifdef BMV2
#include <v1model.p4>
#elif TOFINO
#include <tna.p4>
typedef bit<32> data_t;
#endif


#include "include/headers.p4"
#include "include/parser.p4"
#include "include/int_source.p4"
#include "include/int_transit.p4"
#include "include/int_sink.p4"
#include "include/forward.p4"
#include "include/port_forward.p4"



#ifdef BMV2

control ingress(inout headers hdr, inout metadata meta, inout standard_metadata_t ig_intr_md) {

#elif TOFINO

    control Ingress(inout headers hdr, inout metadata meta, 
        /* Intrinsic */
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md)
    {
        Register<data_t, data_t>(1) h_time;
        RegisterAction<data_t, data_t, data_t>(h_time)
            update_h_time = {
                void apply(inout data_t value, out data_t result) {
                    result = value;
                }
            };
        Register<data_t, data_t>(1) l_time;
        RegisterAction<data_t, data_t, data_t>(l_time)
            update_l_time = {
                void apply(inout data_t value, out data_t result) {
                    result = value;
                }
            };
#endif

        apply {	
#ifdef BMV2
            if (!hdr.udp.isValid() && !hdr.tcp.isValid())
                exit;
#elif TOFINO
            //TODO: find TOFINO equivalent to skip frames other that TCP or UDP

            // time register
            meta.h_time = update_h_time.execute(0);
            meta.l_time = update_l_time.execute(0);
            if(hdr.udp.isValid()){
	            hdr.udp.csum = 0;
            }
#endif

            // in case of INT source port add main INT headers

            Int_source.apply(hdr, meta, ig_intr_md, ig_prsr_md);

            // perform minimalistic L1 or L2 frame forwarding
            // set egress_port for the frame
            #ifdef BMV2
            Forward.apply(hdr, meta, ig_intr_md);          
            PortForward.apply(hdr, meta, ig_intr_md);
            #elif TOFINO
            Forward.apply(hdr, meta, ig_tm_md);          
            PortForward.apply(hdr, meta, ig_tm_md, ig_intr_md);
            #endif

            // in case of sink node make packet clone I2E in order to create INT report
            // which will be send to INT reporting port        
            #ifdef BMV2
            Int_sink_config.apply(hdr, meta, ig_intr_md);    
            #elif TOFINO
            Int_sink_config.apply(hdr, meta, ig_tm_md);    
            #endif
            
        }
    }

#ifdef TOFINO
    parser EgressParser(packet_in        pkt,
        /* User */
        out headers          hdr,
        out metadata         meta,
        /* Intrinsic */
        out egress_intrinsic_metadata_t  eg_intr_md)
    {
        /* This is a mandatory state, required by Tofino Architecture */
        state start {
            pkt.extract(eg_intr_md);
            transition accept;
        }
    }
#endif
#ifdef BMV2

    control egress(inout headers hdr, inout metadata meta, inout standard_metadata_t eg_intr_md) {
#elif TOFINO 

control Egress(inout headers hdr, inout metadata meta, 
            /* Intrinsic */    
            in    egress_intrinsic_metadata_t                  eg_intr_md,
            in    egress_intrinsic_metadata_from_parser_t      eg_prsr_md,
            inout egress_intrinsic_metadata_for_deparser_t     eg_dprsr_md,
            inout egress_intrinsic_metadata_for_output_port_t  eg_oport_md) {
#endif

            apply {

#ifdef BMV2
                Int_transit.apply(hdr, meta, eg_intr_md);
#elif TOFINO
            Int_transit.apply(hdr, meta, eg_intr_md, eg_prsr_md);
#endif

                // in case of the INT sink port remove INT headers
                // when frame duplicate on the INT report port then reformat frame into INT report frame
                #ifdef BMV2
                Int_sink.apply(hdr, meta, eg_intr_md);    
                #elif TOFINO

                Int_sink.apply(hdr, meta, eg_intr_md);    
                #endif
            }
        }



#ifdef BMV2
        V1Switch(ParserImpl(), verifyChecksum(), ingress(), egress(), computeChecksum(), DeparserImpl()) main;
#elif TOFINO
        Pipeline(IngressParser(), Ingress(), IngressDeparser(), EgressParser(), Egress(), EgressDeparser()) pipe;
        Switch(pipe) main;
#endif






