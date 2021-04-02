from scapy.all import *
from struct import *

PCAP_FILE = 'tap0.pcap'

packets = []
prev_packet = 0
prev_id = 0

timestamps = []
cnt = 0
for packet in rdpcap(PCAP_FILE):
    #packet.show()
    timestamps.append(packet.time)
    cnt += 1

time_diff = timestamps[-1] - timestamps[0]

print("Reading file: %s" % PCAP_FILE)
print("Measurement time is %f seconds" % time_diff)
print("Total number of packets is %d" % cnt)
print("Pkt/s: %d" % int(cnt/time_diff))