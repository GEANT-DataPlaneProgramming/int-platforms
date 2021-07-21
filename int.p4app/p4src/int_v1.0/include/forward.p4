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
control Forward(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
#elif TOFINO
control Forward(inout headers hdr, inout metadata meta, inout ingress_intrinsic_metadata_for_tm_t standard_metadata) {
#endif

    action send_to_cpu(bit<9> port) {
#ifdef BMV2
        standard_metadata.egress_spec = port;
#elif TOFINO
        standard_metadata.ucast_egress_port = port; 
#endif
    }
    action send_to_port(bit<9> port) {
#ifdef BMV2
        standard_metadata.egress_spec = port;
#elif TOFINO
        standard_metadata.ucast_egress_port = port;
#endif
    }

    table tb_forward {
        actions = {
            send_to_cpu;
            send_to_port;
        }
        key = {
            hdr.ethernet.dstAddr: ternary;
        }
        size = 31;
    }

    apply {
        tb_forward.apply();
    }
}
