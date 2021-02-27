import scapy.all as scapy

scapy.sniff(iface="veth_cpu", prn=lambda x: x.show())