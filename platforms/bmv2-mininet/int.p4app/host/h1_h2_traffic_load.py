#!/usr/bin/python

# Copyright 2013-present Barefoot Networks, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

from scapy.all import Ether, IP, sendp, get_if_hwaddr, get_if_list, TCP, Raw, UDP
from scapy.config import conf
import sys
from time import sleep, time
from multiprocessing import Process

src_mac = "00:00:00:00:01:01"
data = "ABCDFE" 
src_ip = "10.0.1.1"
dst_mac = "00:00:00:00:02:02"
dst_ip = "10.0.2.2"

interface = [i for i in get_if_list() if "eth0" in i][0]
s = conf.L2socket(iface=interface)

p = Ether(dst=dst_mac,src=src_mac)/IP(frag=0,dst=dst_ip,src=src_ip)
p = p/UDP(sport=0x11FF, dport=0x22FF)/Raw(load=data)

def send(id):
    pkt_cnt = 0
    last_sec = time()
    while True:
        s.send(p)
        pkt_cnt += 1
        if time()-last_sec > 1.0:
            print("[%d]Pkt/s: %d" % (id, pkt_cnt))
            pkt_cnt = 0
            last_sec = time()

    
if __name__ == "__main__":
    procs = []
    for id in range(3):
        proc = Process(target=send, args=(id,)) 
        procs.append(proc)
        proc.start()

    for proc in procs:
        proc.join()