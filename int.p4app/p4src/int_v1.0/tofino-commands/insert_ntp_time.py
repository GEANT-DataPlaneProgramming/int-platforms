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




p4 = bfrt.int.pipe.Ingress.h_time
p4E = bfrt.int.pipe.Ingress.l_time
def setUp():
    global p4
    global p4E
    import time
    nstime = int(time.time()* (10**9))
    print(nstime)
    l_time = nstime & 0xffffffff
    h_time = nstime>>32
    p4.mod(register_index=0, f1=h_time)
    p4E.mod(register_index=0, f1=l_time)
    p4.get(from_hw=True)
    p4E.get(from_hw=True)

setUp()




