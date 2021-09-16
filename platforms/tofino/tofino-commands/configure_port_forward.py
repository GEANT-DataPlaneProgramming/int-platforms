p4 = bfrt.int.pipe.Ingress.PortForward.tb_port_forward
def setUp():
    global p4
    from ipaddress import ip_address
    p4.add_with_send(ingress_port=132,port=134)
    p4.add_with_send(ingress_port=134,port=132)
   
setUp()




