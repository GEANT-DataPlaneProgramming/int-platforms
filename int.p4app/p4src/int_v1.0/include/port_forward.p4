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
 
control PortForward(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {

#elif TOFINO

control PortForward(inout headers hdr, inout metadata meta, inout ingress_intrinsic_metadata_for_tm_t standard_metadata, in ingress_intrinsic_metadata_t ig_intr_md) {

#endif

    action send(bit<9> port) {
        //standard_metadata.egress_port = port;
        #ifdef BMV2
        standard_metadata.egress_spec = port;
        #elif TOFINO
        standard_metadata.ucast_egress_port = port;
        #endif
    }
    // DAMU: Let's remove it
    /*action drop() {*/
        /*#ifdef BMV2*/
        /*// TODO mark_to_drop*/
        /*#elif TOFINO*/
        /*ig_dprsr_md.drop_ctl = 1;*/
        /*#endif*/
    /*}*/

    table tb_port_forward {
        actions = {
            send;
        }
        key = {
            #ifdef BMV2
            standard_metadata.egress_port : exact;
            #elif TOFINO
            ig_intr_md.ingress_port : exact; 
            #endif
        }
        size = 31;
    }

    apply {
        tb_port_forward.apply();
    }
}
