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

#ifdef BMV2

control Int_sink(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {

#elif TOFINO

control Int_sink(inout headers hdr, inout metadata meta, inout ingress_intrinsic_metadata_for_tm_t standard_metadata) {

#endif

    action activate_sink() {
        meta.int_metadata.sink = 1w1;
    }
    table tb_activate_sink {
        actions = {
            activate_sink;
        }
        key = {
            #ifdef BMV2
            standard_metadata.egress_port: exact;
            #elif TOFINO
            standard_metadata.ucast_egress_port: exact;
            #endif
        }
        size = 255;
    }

    apply {
        tb_activate_sink.apply();
        
        // Currently do nothing more - whole packet with INT headers goes to host port for inspection and retieval of INT info
    }
}