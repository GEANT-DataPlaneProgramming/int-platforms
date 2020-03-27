#ifndef _FLOW_LATENCY_DISTRIBUTION_
#define _FLOW_LATENCY_DISTRIBUTION_


const bit<32> FLOW_LATENCY_DIST_CM_ROW = SKETCH_SIZE;  // number of cells in a single hash table row

// The registers to store the counts
register<bit<32>> (FLOW_LATENCY_DIST_CM_ROW) flow_latency_distribution_register1;
register<bit<32>> (FLOW_LATENCY_DIST_CM_ROW) flow_latency_distribution_register2;
register<bit<32>> (FLOW_LATENCY_DIST_CM_ROW) flow_latency_distribution_register3;
register<bit<32>> (FLOW_LATENCY_DIST_CM_ROW) flow_latency_distribution_register4;

control flow_latency_distribution_sketch_update(in register<bit<32>> hashtable,
                        in HashAlgorithm algo,
                        in headers hdr,
                        inout metadata meta,
                        inout bit<32> count_value,
                        inout bit<32> hashtable_address) {
    
    action udp_update_hashtable() {

        hash(hashtable_address,
             algo,
             32w0,
             { hdr.int_first_ingress_tstamp.ingress_tstamp - (bit<32>)meta.intrinsic_metadata.ingress_timestamp},
             FLOW_LATENCY_DIST_CM_ROW);
        hashtable.read(count_value, hashtable_address);
        count_value = count_value + 32w1;
        hashtable.write(hashtable_address, count_value);
    }

    apply {
        if (hdr.udp.isValid()) {
            udp_update_hashtable();
        }
    }
}

control flow_latency_distribution_sketch_control(inout headers hdr,
						inout metadata meta,
						inout standard_metadata_t standard_metadata) {

	flow_latency_distribution_sketch_update() update_hashtable_1;
	flow_latency_distribution_sketch_update() update_hashtable_2;
	flow_latency_distribution_sketch_update() update_hashtable_3;
	flow_latency_distribution_sketch_update() update_hashtable_4;
	
	bit<32> hashtable_address1 = 0;
	bit<32> hashtable_address2 = 0;
	bit<32> hashtable_address3 = 0;
	bit<32> hashtable_address4 = 0;
	bit<32> hashtable_address = 0;
    
    bit<32> count_val1 = 0;
	bit<32> count_val2 = 0;
	bit<32> count_val3 = 0;
	bit<32> count_val4 = 0;
	
	apply {
		// update sketch cells basing on the packet
		update_hashtable_1.apply(flow_latency_distribution_register1, HashAlgorithm.crc32, hdr, meta, count_val1, hashtable_address1);
		update_hashtable_2.apply(flow_latency_distribution_register2, HashAlgorithm.crc32_custom, hdr, meta, count_val2, hashtable_address2);
		update_hashtable_3.apply(flow_latency_distribution_register3, HashAlgorithm.crc16, hdr, meta, count_val3, hashtable_address3);
		update_hashtable_4.apply(flow_latency_distribution_register4, HashAlgorithm.crc16_custom, hdr, meta, count_val4, hashtable_address4);
	}
	
}


#endif
