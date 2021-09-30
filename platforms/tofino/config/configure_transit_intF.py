p4 = bfrt.int.pipe.Egress.Int_transit.tb_int_transit
def setUp():
    global p4
    p4.set_default_with_configure_transit(switch_id=1, l3_mtu=1500)
    p4.dump()

setUp()




