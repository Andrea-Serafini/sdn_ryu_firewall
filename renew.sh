sudo ip -all netns delete
sudo ovs-vsctl del-br LAN1
sudo ./topo.sh

#change with correct IP
sudo ovs-vsctl set-controller LAN1 tcp:10.201.107.109:6633

sudo ovs-ofctl dump-flows LAN1
