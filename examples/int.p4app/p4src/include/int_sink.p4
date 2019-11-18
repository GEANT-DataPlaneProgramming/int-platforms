control Int_sink(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
	
	@name(".activate_sink") action activate_sink() {
        meta.int_metadata.sink = 1w1;
    }
	@name(".tb_activate_sink") table tb_activate_sink {
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
		
		// Currently do nothing more - whole packet with INT headers goes to host port for inspection and retieval of INT info
	}
}