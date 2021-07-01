# Deprecated

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

while 1:
    setUp()




