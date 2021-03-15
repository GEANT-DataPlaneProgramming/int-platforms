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

#define BMV2 1
//#define TOFINO 2

#include <core.p4>

#ifdef BMV2
#include <v1model.p4>
#elif TOFINO
#include <tna.p4>
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
    
#endif
    
	apply {	

        #ifdef BMV2
		if (!hdr.udp.isValid() && !hdr.tcp.isValid())
			exit;
        #elif TOFINO
            //TODO: find TOFINO equivalent to skip frames other that TCP or UDP
        #endif

        Int_source.apply(hdr, meta, ig_intr_md);
        
        Forward.apply(hdr, meta, ig_intr_md);          
        PortForward.apply(hdr, meta, ig_intr_md);
        
        Int_sink_config.apply(hdr, meta, ig_intr_md);    
	}
}

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
        Int_transit.apply(hdr, meta, eg_tm_md, eg_prsr_md);
        #endif
        
        // egress_port need to be set
        Int_sink.apply(hdr, meta, eg_intr_md);    
    }
}

    

#ifdef BMV2
V1Switch(ParserImpl(), verifyChecksum(), ingress(), egress(), computeChecksum(), DeparserImpl()) main;
#elif TOFINO
Pipeline(IngressParser(), Ingress(), IngressDeparser(), EgressParser(), Egress(), EgressDeparser()) pipe;
Switch(pipe) main;
#endif






