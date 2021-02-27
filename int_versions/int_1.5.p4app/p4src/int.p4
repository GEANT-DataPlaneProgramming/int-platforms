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
#include "include/gtp.p4"
#include "include/forward.p4"


control ingress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
	
	Int_source() int_source;
	Int_transit() int_transit;
	Int_sink() int_sink;
	
	Gtp_tunnel() gtp;
	Forward() forward;
	
	apply {	
		
		if (!hdr.udp.isValid() && !hdr.tcp.isValid())
			exit;
			
		int_source.apply(hdr, meta, standard_metadata);
		int_transit.apply(hdr, meta, standard_metadata);
		int_sink.apply(hdr, meta, standard_metadata);
		
		gtp.apply(hdr, meta, standard_metadata);
		
		forward.apply(hdr, meta, standard_metadata);
	}
}

V1Switch(ParserImpl(), verifyChecksum(), ingress(), egress(), computeChecksum(), DeparserImpl()) main;



