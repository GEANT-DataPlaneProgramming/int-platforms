p4 = bfrt.int.pipe.Ingress.Int_source.tb_int_source
def setUp():
    global p4
    from ipaddress import ip_address
    p4.add_with_configure_source(srcAddr=ip_address("10.0.1.1"),
                                                    srcAddr_mask=0xFFFFFFFF,
                                                    dstAddr=ip_address("10.0.2.2"),
                                                    dstAddr_mask=0xFFFFFFFF,
                                                    l4_src=0x11FF,
                                                    l4_src_mask=0x0000,
                                                    l4_dst=0x22FF,
                                                    l4_dst_mask=0x0000,
                                                    max_hop = 4,
                                                    hop_metadata_len = 10,
                                                    ins_cnt = 8,
                                                    ins_mask = 0xFF)
    p4.add_with_configure_source(srcAddr=ip_address("10.0.3.3"),
                                                    srcAddr_mask=0xFFFFFFFF,
                                                    dstAddr=ip_address("10.0.4.4"),
                                                    dstAddr_mask=0xFFFFFFFF,
                                                    l4_src=0x11FF,
                                                    l4_src_mask=0x0000,
                                                    l4_dst=0x4268,
                                                    l4_dst_mask=0x0000,
                                                    max_hop = 4,
                                                    hop_metadata_len = 6,
                                                    ins_cnt = 4,
                                                    ins_mask = 0xCC)
    p4.dump()
    # modify an existing entry
    p4.mod_with_configure_source(srcAddr=ip_address("10.0.3.3"),
                                                    srcAddr_mask=0xFFFFFFFF,
                                                    dstAddr=ip_address("10.0.5.5"),
                                                    dstAddr_mask=0xFFFFFFFF,
                                                    l4_src=0x11FF,
                                                    l4_src_mask=0x0000,
                                                    l4_dst=0x4268,
                                                    l4_dst_mask=0x0000,
                                                    max_hop = 4,
                                                    hop_metadata_len = 6,
                                                    ins_cnt = 4,
                                                    ins_mask = 0xCC)
    p4.dump()
    # clear entries
    # p4.clear()

setUp()




