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
import random, string
from time import sleep
from collections import Counter
import threading

def send_random_traffic(dst):
    dst_mac = None
    dst_ip = None
    interface = None
    #print get_if_list()
    src_mac = [get_if_hwaddr(i) for i in get_if_list() if "eth0" in i]
    interface = [i for i in get_if_list() if "eth0" in i][0]
    if len(src_mac) < 1:
        print ("No interface for output")
        sys.exit(1)
    src_mac = src_mac[0]
    src_ip = None
    if src_mac == "00:00:00:00:01:01":
        src_ip = "10.0.1.1"
    elif src_mac =="00:00:00:00:02:02":
        src_ip = "10.0.2.2"
    elif src_mac =="00:00:00:00:03:03":
        src_ip = "10.0.3.3"
    else:
        print ("Invalid source host")
        sys.exit(1)

    if dst in ("h1","10.0.1.1"):
        dst_mac = "00:00:00:00:01:01"
        dst_ip = "10.0.1.1"
    elif dst in ("h2","10.0.2.2"):
        dst_mac = "00:00:00:00:02:02"
        dst_ip = "10.0.2.2"
    elif dst in ("h3","10.0.3.3"):
        dst_mac = "00:00:00:00:03:03"
        dst_ip = "10.0.3.3"
    else:
        print ("Invalid host to send to")
        sys.exit(1)

    src_mac = "10:10:10:10:10:10"
    data = "ABCDFE" 
    src_ip = "10.0.10.10"
    s = conf.L2socket(iface=interface)
     
    p = Ether(dst=dst_mac,src=src_mac)/IP(frag = 5868,dst=dst_ip,src=src_ip)
    p = p/UDP(sport=0x00FF, dport=0x00FF)/Raw(load=data)
    s.send(p)

def run_in_background():
    thread = threading.Thread(target=send_random_traffic, args=("h2",))
    thread.daemon = True
    thread.start()

if __name__ == "__main__":
    if len(sys.argv) != 1:
        print("Usage: python send.py dst_host_name")
        sys.exit(1)
    else:
        dst_name = 'h2' #sys.argv[1]
        send_random_traffic(dst_name)
