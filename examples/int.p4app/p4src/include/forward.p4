control Forward(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {

    @name(".send_to_cpu") action send_to_cpu() {
        standard_metadata.egress_port = 9w128;
    }
    @name(".send_to_eth") action send_to_eth() {
        standard_metadata.egress_port = 9w0;
    }
    @name(".send_to_port") action send_to_port(bit<9> port) {
        standard_metadata.egress_port = port;
        standard_metadata.egress_spec = port;
    }

    @name(".tb_forward") table tb_forward {
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