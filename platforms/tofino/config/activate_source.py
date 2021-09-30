p4 = bfrt.int.pipe.Ingress.Int_source.tb_activate_source
def setUp():
    global p4
    p4.add_with_activate_source(ingress_port=132)
    p4.dump()

setUp()




