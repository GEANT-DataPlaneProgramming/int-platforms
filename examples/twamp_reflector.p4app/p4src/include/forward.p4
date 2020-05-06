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
 
control Forward(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {

    action send_to_cpu() {
        standard_metadata.egress_port = 9w128;
    }
    action send_to_eth() {
        standard_metadata.egress_port = 9w0;
    }
    action send_to_port(bit<9> port) {
        standard_metadata.egress_port = port;
        standard_metadata.egress_spec = port;
    }

    table tb_forward {
        actions = {
            send_to_cpu;
            send_to_eth;
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