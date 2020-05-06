/*
 * Copyright 2020-present PSNC
 *
 * Author: Damian Parniewicz
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
#include "include/forward.p4"
#include "include/twamp_reflector.p4"
#include "include/cpu_loopback.p4"
#include "include/arp_responder.p4"

control ingress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
	
	apply {	
		
        // Apply twamp processing before other packet processing (eg.: switching, routing, etc).
        TwampReflector.apply(hdr, meta, standard_metadata);
        
        // expose CPU communication (eg.: TWAMP server) via Loopback mechanism
        CPU_Loopback.apply(hdr, meta, standard_metadata);
        
        //Handling ARP requests for Loopback and TwampReflector services
        ARP_Responder.apply(hdr, meta, standard_metadata);
        
        //Forward.apply(hdr, meta, standard_metadata);
		
	}
}

V1Switch(ParserImpl(), verifyChecksum(), ingress(), egress(), computeChecksum(), DeparserImpl()) main;



