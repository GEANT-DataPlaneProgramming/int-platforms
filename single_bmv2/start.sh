#!/bin/bash

# turn on bash's job control
set -m

# Start the primary process and put it in the background
simple_switch -i 0@eth0 -i 1@eth1  int.json --thrift-port 9090 --pcap &

# Start the helper process
python /examples/single_bmv2/control.py

# now we bring the primary process back into the foreground
# and leave it there
fg %1