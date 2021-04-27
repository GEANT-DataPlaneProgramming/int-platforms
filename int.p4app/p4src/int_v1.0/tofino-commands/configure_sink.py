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




p4 = bfrt.int.pipe.Egress.Int_sink.Int_report.tb_int_reporting
def setUp():
    global p4
    from ipaddress import ip_address
    p4.set_default_with_send_report(dp_mac='f6:61:c0:6a:00:00', dp_ip=ip_address('10.0.1.1'), collector_mac='f6:61:c0:6a:14:21', collector_ip=ip_address('10.0.0.254'), collector_port=6000)
    p4.dump()

setUp()




