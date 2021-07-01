
p4 = bfrt.int.pipe.Egress.Int_sink.Int_report.tb_int_reporting
def setUp():
    global p4
    from ipaddress import ip_address
    p4.set_default_with_send_report(dp_mac='f6:61:c0:6a:00:00', dp_ip=ip_address('10.0.1.1'), collector_mac='f6:61:c0:6a:14:21', collector_ip=ip_address('10.0.0.254'), collector_port=6000)
    p4.dump()

setUp()




