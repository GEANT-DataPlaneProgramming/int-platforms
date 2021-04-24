################################################################################
# BAREFOOT NETWORKS CONFIDENTIAL & PROPRIETARY
#
# Copyright (c) 2019-present Barefoot Networks, Inc.
#
# All Rights Reserved.
#
# NOTICE: All information contained herein is, and remains the property of
# Barefoot Networks, Inc. and its suppliers, if any. The intellectual and
# technical concepts contained herein are proprietary to Barefoot Networks, Inc.
# and its suppliers and may be covered by U.S. and Foreign Patents, patents in
# process, and are protected by trade secret or copyright law.  Dissemination of
# this information or reproduction of this material is strictly forbidden unless
# prior written permission is obtained from Barefoot Networks, Inc.
#
# No warranty, explicit or implicit is provided, unless granted under a written
# agreement with Barefoot Networks, Inc.
#
################################################################################




p4 = bfrt.int.pipe.Ingress.Int_source.tb_int_source
def setUp():
    global p4
    from ipaddress import ip_address
    p4.add_with_configure_source(srcaddr=ip_address("10.0.1.1"),
                                                    srcaddr_mask=0xFFFFFFFF,
                                                    dstaddr=ip_address("10.0.2.2"),
                                                    dstaddr_mask=0xFFFFFFFF,
                                                    l4_src=0x11FF,
                                                    l4_src_mask=0x0000,
                                                    l4_dst=0x22FF,
                                                    l4_dst_mask=0x0000,
                                                    max_hop = 4,
                                                    hop_metadata_len = 10,
                                                    ins_cnt = 8,
                                                    ins_mask = 0xFF)
    p4.dump()
    p4.add_with_configure_source(srcaddr=ip_address("150.254.169.196"),
                                                    srcaddr_mask=0xFFFFFFFF,
                                                    dstaddr=ip_address("195.113.172.46"),
                                                    dstaddr_mask=0xFFFFFFFF,
                                                    l4_src=0x11FF,
                                                    l4_src_mask=0x0000,
                                                    l4_dst=0x4268,
                                                    l4_dst_mask=0x0000,
                                                    max_hop = 4,
                                                    hop_metadata_len = 6,
                                                    ins_cnt = 4,
                                                    ins_mask = 0xCC)
    p4.dump()

setUp()




