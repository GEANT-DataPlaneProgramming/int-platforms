/*
 * Copyright 2017-present Open Networking Foundation
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
 
 const bit<32> SKETCH_SIZE = 50;

#include "latency_distribution.p4"

control Int_sink(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {

    action activate_sink() {
        meta.int_metadata.sink = 1w1;
    }
    
    action update_owamp_distributions() {
        // INFO: bvm2 target don't accept this valid P4_16 statement
        // 'action_run' used instead in the control
        // flow_latency_distribution_sketch_control.apply(hdr, meta, standard_metadata);
    }
    
    table tb_int_sink {
        actions = {
            update_owamp_distributions;
        }
    }
    
    table tb_activate_sink {
        actions = {
            activate_sink;
        }
        key = {
            standard_metadata.egress_port: exact;
        }
        size = 255;
    }

    apply {
        tb_activate_sink.apply();
        
        if (meta.int_metadata.sink == 1w1) {
            switch(tb_int_sink.apply().action_run) {
                update_owamp_distributions:  { flow_latency_distribution_sketch_control.apply(hdr, meta, standard_metadata); return;}
            }
        }
    }
}