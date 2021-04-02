import subprocess
import time
from mininet.topo import Topo

_THRIFT_BASE_PORT = 22222

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



       
def configure_hosts(net, nb_hosts):
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


def configure_switches(net, nb_switches, args):    
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

        s = net.get('s%d' % (i + 1))
        s.cmd("sysctl -w net.ipv6.conf.all.disable_ipv6=1")
        s.cmd("sysctl -w net.ipv6.conf.default.disable_ipv6=1")
        s.cmd("sysctl -w net.ipv6.conf.lo.disable_ipv6=1")
        s.cmd("sysctl -w net.ipv4.tcp_congestion_control=reno")
        s.cmd("iptables -I OUTPUT -p icmp --icmp-type destination-unreachable -j DROP")
