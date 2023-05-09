##################################################################
# Create 3 hosts - 1 switches - 1 network                                       
                                  #
##################################################################

for N in 1
do
    ovs-vsctl add-br LAN$N
	for H in 1 2 3
	do
		NH="H"$H
		MAC="00:00:00:"$N$H":"$N$H":"$N$H
		ip netns add $NH
		ip link add veth0 address "$MAC" type veth peer name eth-$NH
		ip link set veth0 netns $NH
		ip netns exec $NH ip link set veth0 up
		ip netns exec $NH sysctl -w net.ipv6.conf.all.disable_ipv6=1
		ip netns exec $NH sysctl -w net.ipv6.conf.default.disable_ipv6=1
		ip netns exec $NH sysctl -w net.ipv6.conf.lo.disable_ipv6=1
		MS="Host "$NH" done"
		ovs-vsctl add-port LAN$N eth-$NH
		ip link set eth-$NH up
		echo $MS
	done
	ovs-vsctl list-ports LAN$N 
done

ip netns exec H1 ip addr add 192.168.1.1/24 dev veth0
ip netns exec H2 ip addr add 192.168.1.2/24 dev veth0
ip netns exec H3 ip addr add 192.168.1.3/24 dev veth0

