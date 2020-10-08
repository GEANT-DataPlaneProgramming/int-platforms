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

#include <core.p4>
#include <v1model.p4>

#include "include/headers.p4"
#include "include/parser.p4"
#include "include/int_source.p4"
#include "include/int_transit.p4"
#include "include/int_sink.p4"
#include "include/forward.p4"
#include "include/port_forward.p4"

#ifdef BMV2

control ingress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {

#elif TOFINO

control Ingress(inout headers hdr, inout metadata meta, 
    /* Intrinsic */
    in ingress_intrinsic_metadata_t ig_intr_md,
    in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
    inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
    inout ingress_intrinsic_metadata_for_tm_t ig_tm_md)
    
#endif
    
	Int_source() int_source;
	Int_transit() int_transit;
	Int_sink() int_sink;
	
	Forward() forward;
	
	apply {	

        #ifdef BMV2
		if (!hdr.udp.isValid() && !hdr.tcp.isValid())
			exit;
        #elif TOFINO
            //TODO: find TOFINO equivalent to skip frames other that TCP or UDP
        #endif

        int_source.apply(hdr, meta, 
        #ifdef BMV2
                                 standard_metadata);
        #elif TOFINO
                                 ig_intr_md);
        #endif
                                 
        int_transit.apply(hdr, meta, 
        #ifdef BMV2
                                 standard_metadata);
        #elif TOFINO
                                 ig_prsr_md, ig_tm_md);
        #endif
                                 
        int_sink.apply(hdr, meta, 
        #ifdef BMV2
                                 standard_metadata);
        #elif TOFINO
                                 ig_intr_md);
        #endif                         

        forward.apply(hdr, meta, 
        #ifdef BMV2
                                 standard_metadata);
        #elif TOFINO
                                 ig_intr_md);
        #endif
                                 
        PortForward.apply(hdr, meta, 
        #ifdef BMV2
                                 standard_metadata);
        #elif TOFINO
                                 ig_intr_md); 
        #endif
        
#if TOFINO 
        ig_tm_md.bypass_egress = 1;
#endif
	}
}

#ifdef BMV2
V1Switch(ParserImpl(), verifyChecksum(), ingress(), egress(), computeChecksum(), DeparserImpl()) main;
#endif


