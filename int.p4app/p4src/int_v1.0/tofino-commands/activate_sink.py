p4 = bfrt.int.pipe.Ingress.Int_sink_config.tb_int_sink
def setUp():
    global p4
    # To configure when Tofino switch is used as a sink node 
    p4.add_with_configure_sink(ucast_egress_port=132, sink_reporting_port=132)
    p4.dump()

setUp()




