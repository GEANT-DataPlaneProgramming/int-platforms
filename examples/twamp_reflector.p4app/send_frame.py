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

from scapy.all import Ether, IP, sendp, get_if_hwaddr, get_if_list, TCP, Raw, UDP, ARP
from scapy.config import conf
import sys
import random, string
from time import sleep
from collections import Counter
import threading

def send_arp_req():
    interface = [i for i in get_if_list() if "eth0" in i][0]
    s = conf.L2socket(iface=interface)
    p = Ether(dst= "FF:FF:FF:FF:FF:FF",src="00:00:00:00:01:01") / ARP (op=ARP.who_has, psrc='10.0.1.1', pdst='10.0.0.254')
    #/IP(frag = 5868,dst=dst_ip,src=src_ip)
    #p = p/UDP(sport=0x00FF, dport=0x00FF)/Raw(load=data)
    s.send(p)

if __name__ == "__main__":
    if len(sys.argv) != 1:
        print("Usage: python send.py dst_host_name")
        sys.exit(1)
    else:
        send_arp_req()
