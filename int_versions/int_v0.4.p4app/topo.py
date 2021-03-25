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

from mininet.net import Mininet
from mininet.topo import Topo
from mininet.log import setLogLevel
from mininet.cli import CLI
from mininet.link import Intf
from mininet.util import quietRun

from p4_mininet import P4Switch, P4Host

import argparse
import os
import subprocess
import threading
import re
import sys
import time

_THIS_DIR = os.path.dirname(os.path.realpath(__file__))
_THRIFT_BASE_PORT = 22222


CONTROL_CPU_IP = "10.0.0.254"
CONTROL_INT_COLLECTOR_MAC = 'f6:61:c0:6a:14:21'

# install additional libraries
os.system("dpkg -i /tmp/libraries/bridge-utils_1.5-13+deb9u1_amd64.deb")


parser = argparse.ArgumentParser(description='Mininet demo')
parser.add_argument('--behavioral-exe', help='Path to behavioral executable',
                    type=str, action="store", required=True)
parser.add_argument('--json', help='Path to JSON config file',
                    type=str, action="store", required=True)
parser.add_argument('--cli', help='Path to BM CLI',
                    type=str, action="store", required=True)
args = parser.parse_args()

class MyTopo(Topo):
    def __init__(self, sw_path, json_path, nb_hosts, nb_switches, links, **opts):
        # Initialize topology and default options
        Topo.__init__(self, **opts)
        for i in xrange(nb_switches):
           self.addSwitch('s%d' % (i + 1),
                            sw_path = sw_path,
                            json_path = json_path,
                            thrift_port = _THRIFT_BASE_PORT + i,
                            pcap_dump = False,
                            device_id = i,
                            enable_debugger = True)

        for h in xrange(nb_hosts):
            self.addHost('h%d' % (h + 1), ip="10.0.%d.%d" % ((h + 1) , (h + 1)),
                    mac="00:00:00:00:0%d:0%d" % ((h+1), (h+1)))

        for a, b in links:
            self.addLink(a, b)

def read_topo():
    nb_hosts = 0
    nb_switches = 0
    links = []
    with open("topo.txt", "r") as f:
        line = f.readline()[:-1]
        w, nb_switches = line.split()
        assert(w == "switches")
        line = f.readline()[:-1]
        w, nb_hosts = line.split()
        assert(w == "hosts")
        for line in f:
            if not f: break
            a, b = line.split()
            links.append( (a, b) )
    return int(nb_hosts), int(nb_switches), links

def connect(thrift_port):
    return subprocess.Popen(['simple_switch_CLI', '--thrift-port', str(thrift_port)], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
  

def readRegister(register, thrift_port, idx=None):
        p = subprocess.Popen(['simple_switch_CLI', '--thrift-port', str(thrift_port)], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        if idx is not None:
            stdout, stderr = p.communicate(input="register_read %s %d" % (register, idx))
            reg_val = filter(lambda l: ' %s[%d]' % (register, idx) in l, stdout.split('\n'))[0].split('= ', 1)[1]
            return long(reg_val)
        else:
            stdout, stderr = p.communicate(input="register_read %s" % (register))
            return stdout
            
def writeRegister(thrift_port, register, idx, value):
    p = connect(thrift_port)
    entry = "register_write %s %d %d" % (register, idx, value)
    print(entry)
    stdout, stderr = p.communicate(input=entry)
    # Parsing line like: 'RuntimeCmd: src_distribution_register1[3761]'
    for line in stdout.splitlines():
        #line = line.decode()
        print(line)


def setup_start_time():
    offset = int(time.time()*1e9)
    offset -= 1000 * 1e6 # substract 1000 ms  to compesate a little earlier bmv2 start
    print("Setting time offset %d", offset)
    for port in [22222, 22223, 22224]:
        writeRegister(thrift_port=port, register='start_timestamp', idx=0, value=offset)
        
def create_link_to_external_interface(switch, external_interface_name):
    print  '*** Adding hardware interface', external_interface_name, 'to switch', switch.name, '\n'
    _intf = Intf(external_interface_name, node=switch)
    

def quietRunNs(command, namespace='ns_int', display=True, shell=True):
    if display:
        print "Namespace %s: %s" % (namespace, command)
    quietRun('ip netns exec %s %s' % (namespace, command), shell=shell)
    
def _quietRun(command):
    print command
    quietRun( command, shell=True )
    
def create_int_collection_network(switches):
    '''
    Create a INT collection network composed of a bridge, virtual links to each p4 switch and virtual link to the INT collector
    '''
    print "..... CREATING INT COLLECTION NETWORK  ........"
    # INT collection infrastructure resides within 'ns1' namespace
    _quietRun( 'ip netns add ns_int')
    
    #create bridge acting as hub
    bridge_name = 'int_collection'
    quietRunNs( 'brctl addbr %s' % bridge_name)
    
    create_int_collector_link(bridge_name)
    
    for id, switch in enumerate(switches):
        print "Adding switch id %d" % id 
        create_dp_cpu_link(id, switch, bridge_name)

    quietRunNs( 'ip link set up dev %s' % bridge_name)
    
    create_internet_connectivity()
    start_int_collector()
    
def start_int_collector():
    print "\nRunning INT collector"
    collector_cmd = 'ip netns exec ns_int python /tmp/scripts/int_collector_influx.py &> /dev/null'
    print collector_cmd
    os.system(collector_cmd)
    
def create_internet_connectivity():
    _quietRun( 'ip link add name internet_cont type veth peer name internet_coll')
    
    _quietRun( 'ip link set internet_coll netns ns_int')
    quietRunNs( 'ifconfig internet_coll %s/24' % "192.168.0.2")
    quietRunNs( 'ip link set dev internet_coll up')
    
    _quietRun( 'ifconfig internet_cont %s/24' % "192.168.0.1")
    _quietRun( 'ip link set dev internet_cont up')
 
def create_int_collector_link(bridge_name):
    '''
    Add virtual link for the INT collector
    '''
    _quietRun( 'ip link add name int_bridge type veth peer name int_collector')
    _quietRun( 'ip link set int_bridge netns ns_int')
    _quietRun( 'ip link set int_collector netns ns_int')

    quietRunNs( 'ifconfig int_collector hw ether %s' % CONTROL_INT_COLLECTOR_MAC)
    quietRunNs( 'ip link set dev int_bridge up')
    quietRunNs( 'ip link set dev int_collector up')
    for off in "rx tx sg tso ufo gso gro lro rxvlan txvlan rxhash".split(' '):
        quietRunNs( '/sbin/ethtool --offload int_bridge %s off' % off, display=False)
        quietRunNs( '/sbin/ethtool --offload int_collector %s off' % off, display=False)    
    quietRunNs( 'ifconfig int_collector %s/24' % CONTROL_CPU_IP)
    
    quietRunNs( 'sysctl -w net.ipv6.conf.int_bridge.disable_ipv6=1')
    quietRunNs( 'sysctl -w net.ipv6.conf.int_collector.disable_ipv6=1')
    
    quietRunNs('brctl addif %s int_bridge' % bridge_name)

    
def create_dp_cpu_link(id, switch, bridge_name):
    '''
    Add virtual link within the INT collection network for each p4 switch
    '''
    _quietRun( 'ip link add name veth_dp_%i type veth peer name veth_cpu_%i' % (id, id))
    
    dp_mac = 'f6:61:c0:6a:00:0%i' % id

    _quietRun( 'ip link set veth_cpu_%i netns ns_int' % id)
    _quietRun( 'ifconfig veth_dp_%i hw ether %s' % (id, dp_mac))
    _quietRun( 'ip link set dev veth_dp_%i up' % id)
    quietRunNs( 'ip link set dev veth_cpu_%i up' % id)
    for off in "rx tx sg tso ufo gso gro lro rxvlan txvlan rxhash".split(' '):
        quietRun( '/sbin/ethtool --offload veth_dp_%i %s off' % (id, off))
        quietRunNs( '/sbin/ethtool --offload veth_cpu_%i %s off' % (id, off), display=False)
    
    quietRunNs( 'sysctl -w net.ipv6.conf.veth_dp_%i.disable_ipv6=1' % id)
    quietRunNs( 'sysctl -w net.ipv6.conf.veth_cpu_%i.disable_ipv6=1' % id)
    
    quietRunNs('brctl addif %s veth_cpu_%i' % (bridge_name, id))
    
    _intf = Intf('veth_dp_%i' % id, node=switch) 
    veth_dp_port = switch.intfNames().index('veth_dp_%i' % id)
    print  '*** Adding hardware interface', 'veth_dp_%i' % id, 'to switch', switch.name, 'with port index', veth_dp_port, '\n'
    return veth_dp_port
    

def main():
    nb_hosts, nb_switches, links = read_topo()
    topo = MyTopo(args.behavioral_exe,
                  args.json,
                  nb_hosts, nb_switches, links)

    net = Mininet(topo = topo,
                  host = P4Host,
                  switch = P4Switch,
                  controller = None,
                  autoStaticArp=True)

    #create_link_to_external_interface(switch=net.switches[1], external_interface_name='eth1')
    #create_link_to_external_interface(switch=net.switches[2], external_interface_name='eth2')
    
    create_int_collection_network(net.switches)

    net.start()
    
    setup_start_time()

    for n in xrange(nb_hosts):
        h = net.get('h%d' % (n + 1))
        for off in ["rx", "tx", "sg"]:
            cmd = "/sbin/ethtool --offload eth0 %s off" % off
            print cmd
            h.cmd(cmd)
        print "disable ipv6"
        h.cmd("sysctl -w net.ipv6.conf.all.disable_ipv6=1")
        h.cmd("sysctl -w net.ipv6.conf.default.disable_ipv6=1")
        h.cmd("sysctl -w net.ipv6.conf.lo.disable_ipv6=1")
        h.cmd("sysctl -w net.ipv4.tcp_congestion_control=reno")
        h.cmd("iptables -I OUTPUT -p icmp --icmp-type destination-unreachable -j DROP")

    time.sleep(1)

    for i in xrange(nb_switches):
        cmd = [args.cli, "--json", args.json,
               "--thrift-port", str(_THRIFT_BASE_PORT + i)
               ]
        with open("commands/commands"+str((i+1))+".txt", "r") as f:
            print " ".join(cmd)
            try:
                output = subprocess.check_output(cmd, stdin = f)
                print output
            except subprocess.CalledProcessError as e:
                print e
                print e.output

        s = net.get('s%d' % (n + 1))
        s.cmd("sysctl -w net.ipv6.conf.all.disable_ipv6=1")
        s.cmd("sysctl -w net.ipv6.conf.default.disable_ipv6=1")
        s.cmd("sysctl -w net.ipv6.conf.lo.disable_ipv6=1")
        s.cmd("sysctl -w net.ipv4.tcp_congestion_control=reno")
        s.cmd("iptables -I OUTPUT -p icmp --icmp-type destination-unreachable -j DROP")

    net.get('h1').cmd('python /tmp/host/udp_frame.py')
    time.sleep(1)
    print "Ready !"

    CLI( net )
    net.stop()

if __name__ == '__main__':
    setLogLevel( 'info' )
    main()
