# Copyright 2020-2021 PSNC
# Author: Damian Parniewicz
#
# Created in the GN4-3 project.
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
# limitations under the License

from mininet.link import Intf
from mininet.util import quietRun

import os
import subprocess



CONTROL_CPU_IP = "10.0.0.254"
CONTROL_INT_COLLECTOR_MAC = 'f6:61:c0:6a:14:21'



def quietRunNs(command, namespace='ns_int', display=True, shell=True):
    if display:
        print("Namespace %s: %s" % (namespace, command))
    quietRun('ip netns exec %s %s' % (namespace, command), shell=shell)
    
    
def _quietRun(command):
    print(command)
    quietRun( command, shell=True )
    
    
def create_int_collection_network(switches, influxdb):
    '''
    Create a INT collection network composed of a bridge, virtual links to each p4 switch and virtual link to the INT collector
    '''
    print("..... CREATING INT COLLECTION NETWORK  ........")
    # INT collection infrastructure resides within 'ns1' namespace
    _quietRun( 'ip netns add ns_int')
    
    #create bridge acting as hub
    bridge_name = 'int_collection'
    quietRunNs( 'brctl addbr %s' % bridge_name)
    
    create_int_collector_link(bridge_name)
    
    for id, switch in enumerate(switches):
        print("Adding switch id %d" % id) 
        create_dp_cpu_link(id, switch, bridge_name)

    quietRunNs( 'ip link set up dev %s' % bridge_name)
    
    create_internet_connectivity()
    start_int_collector(influxdb)
    
    
def start_int_collector(influxdb):
    print("\nRunning INT collector")
    
    # forward influx TCP connections to PSNC influx instance (not accessible directly from ns_int namespace where INT collector runs) 
    print("socat TCP-LISTEN:8086,fork TCP:%s" % influxdb)
    subprocess.Popen(
        ['/usr/bin/socat','TCP-LISTEN:8086,fork','TCP:%s'%influxdb],
        stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.STDOUT
    )
    
    collector_cmd = 'ip netns exec ns_int python3 /tmp/utils/int_collector_influx.py -i 6000 -H 192.168.0.1:8086 -d 0 &> /dev/null'
    print(collector_cmd)
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
    print('*** Adding hardware interface', 'veth_dp_%i' % id, 'to switch', switch.name, 'with port index', veth_dp_port, '\n')
    return veth_dp_port
    
    
def create_link_to_external_interface(switch, external_interface_name):
    print('*** Adding hardware interface', external_interface_name, 'to switch', switch.name, '\n')
    _intf = Intf(external_interface_name, node=switch)
   
    
