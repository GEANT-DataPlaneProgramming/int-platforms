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
from time import sleep
import threading

def send_frames():
    src_mac = "00:00:00:00:03:03"
    dst_mac = "26:82:e5:03:8f:6e"  # FBK tap0 MAC address
    src_ip = "10.0.30.30"
    dst_ip = "10.0.2.2"
    data = "ABCDFE" 
    interface = [i for i in get_if_list() if "eth0" in i][0]
    s = conf.L2socket(iface=interface)
     
    p = Ether(dst=dst_mac,src=src_mac)/IP(frag=0,dst=dst_ip,src=src_ip)
    p = p/UDP(sport=0x11FF, dport=0x22FF)/Raw(load=data)
    print("Bytes sent: %d" % s.send(p))

def run_in_background():
    thread = threading.Thread(target=send_frames)
    thread.daemon = True
    thread.start()

if __name__ == "__main__":
    while True:
        send_frames()
        sleep(1)
