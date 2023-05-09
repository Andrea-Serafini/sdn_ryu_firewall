# sdn_ryu_firewall

Developed for:
> Laboratory of Network Programmability and Automation - Programmable Networking

## Assignment
The assignment required to implement a topology with 1 switch and 3 hosts and a firewall with the following rules:
- default "Deny"
- H1 and H2 can talk for any IP traffic
- H1 can talk to port 80 of H3 only

## Development
The project is composed of a script to create the sdn topology and a custom ryu controller.
In addition there can be scripts used to execute some repetitive sets of commands.

## Execution
- Clone the repository in the `ryu/ryu/app` directory
- Open the repo folder in two terminals:
	```
	cd ryu/ryu/app/sdn_ryu_firewall
	```
- In the first terminal start the controller:
	```
	ryu-manager firewall_simple_switch_13.py
	```
- Check firewall IP running wireshark as `sudo` and change it in `renew.sh`
- In the second terminal run the script to clean previous sdn and restart a new one:
	```
	sudo ./renew.sh
	```
	Expected output:
	```
	ovs-vsctl: no bridge named LAN1
	net.ipv6.conf.all.disable_ipv6 = 1
	net.ipv6.conf.default.disable_ipv6 = 1
	net.ipv6.conf.lo.disable_ipv6 = 1
	Host H1 done
	net.ipv6.conf.all.disable_ipv6 = 1
	net.ipv6.conf.default.disable_ipv6 = 1
	net.ipv6.conf.lo.disable_ipv6 = 1
	Host H2 done
	net.ipv6.conf.all.disable_ipv6 = 1
	net.ipv6.conf.default.disable_ipv6 = 1
	net.ipv6.conf.lo.disable_ipv6 = 1
	Host H3 done
	eth-H1
	eth-H2
	eth-H3
	 cookie=0x0, duration=0.029s, table=0, n_packets=0, n_bytes=0, priority=0 actions=CONTROLLER:65535
	```
- To check the switch status you can use:
	```
	sudo ovs-vsctl show
	```
	Expected output:
	```
	eef462c4-a4bf-4893-9724-d27d18c02cbf
	    Bridge LAN1
	        Controller "tcp:10.201.107.109:6633"
	            is_connected: true
	        Port LAN1
	            Interface LAN1
	                type: internal
	        Port eth-H1
	            Interface eth-H1
	        Port eth-H2
	            Interface eth-H2
	        Port eth-H3
	            Interface eth-H3
	    ovs_version: "2.17.3"
	```

## Testing

To test the behaviour of the net the following commands can be used:

```
sudo ip netns exec H1 ping -c 3 192.168.1.2
sudo ip netns exec H2 ping -c 3 192.168.1.1

sudo ip netns exec H1 nping --tcp -p 80 192.168.1.3
sudo ip netns exec H3 nping --tcp -g 80 192.168.1.1
```

As a result with `sudo ovs-ofctl dump-flows LAN1` we can se the rules in the switch requested by the assignment:

```
 cookie=0x0, duration=16.106s, table=0, n_packets=6, n_bytes=532, priority=1,in_port="eth-H1",dl_src=00:00:00:11:11:11,dl_dst=00:00:00:12:12:12 actions=output:"eth-H2"
 cookie=0x0, duration=16.104s, table=0, n_packets=6, n_bytes=532, priority=1,in_port="eth-H2",dl_src=00:00:00:12:12:12,dl_dst=00:00:00:11:11:11 actions=output:"eth-H1"
 cookie=0x0, duration=11.952s, table=0, n_packets=9, n_bytes=486, priority=1,tcp,nw_src=192.168.1.1,nw_dst=192.168.1.3,tp_dst=80 actions=output:"eth-H3"
 cookie=0x0, duration=11.950s, table=0, n_packets=9, n_bytes=486, priority=1,tcp,nw_src=192.168.1.3,nw_dst=192.168.1.1,tp_src=80 actions=output:"eth-H1"
 cookie=0x0, duration=125.172s, table=0, n_packets=15, n_bytes=934, priority=0 actions=CONTROLLER:65535
```

If other packets are sent out of this permitted routes they will be dropped by the controller and there will be no communication following the `default Deny` behaviour, examples are:
```
sudo ip netns exec H1 ping -c 3 192.168.1.3
sudo ip netns exec H2 ping -c 3 192.168.1.3

sudo ip netns exec H1 nping --tcp -p 8080 192.168.1.3
sudo ip netns exec H3 nping --tcp -g 80 192.168.1.2
```


