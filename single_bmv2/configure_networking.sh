sudo ip link add dev veth0-bmv2 type veth peer name veth1-bmv2

sudo ip addr add 10.0.0.1/24 dev veth0-bmv2
sudo ip addr add 10.0.0.2/24 dev veth1-bmv2

sudo ip link set dev veth0-bmv2 up
sudo ip link set dev veth1-bmv2 up


sudo docker network create -d macvlan \
  --subnet 192.168.150.0/24 \
  --gateway 192.168.150.1 \
  --ip-range=192.168.150.208/28 \
  -o parent=veth1-bmv2 veth1-bmv2-macvlan
  
  
sudo docker network create -d macvlan \
  --attachable \
  --subnet 150.254.169.198/30 \
  --gateway 150.254.169.198 \
  --ip-range=150.254.169.198/30 \
  -o parent=eno49 macvlan_tap0

