# Network Namespace

## Connect 2 different namespaces
### Create network namespaces
```bash
ip netns add blue
ip netns add red
```
```bash
# ip netns list
red
blue
```

### Create a veth pair
```bash
ip link add veth-red type veth peer name veth-blue
```
```bash
# ip link show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
    link/ether fa:16:3e:ef:1f:5f brd ff:ff:ff:ff:ff:ff
12: veth-blue@veth-red: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether b6:1c:3c:66:c7:98 brd ff:ff:ff:ff:ff:ff
13: veth-red@veth-blue: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether ea:91:0b:88:87:88 brd ff:ff:ff:ff:ff:ff
```

### Attach veth to namespaces
```bash
ip link set veth-red netns red

ip link set veth-blue netns blue
```

```bash
# ip link show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
    link/ether fa:16:3e:ef:1f:5f brd ff:ff:ff:ff:ff:ff

# ip netns exec red ip link show
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
13: veth-red@if12: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether ea:91:0b:88:87:88 brd ff:ff:ff:ff:ff:ff link-netnsid 1

# ip netns exec blue ip link show
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
12: veth-blue@if13: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether b6:1c:3c:66:c7:98 brd ff:ff:ff:ff:ff:ff link-netnsid 0
```

### Assign IP
```bash
ip netns exec red ip addr add 192.168.100.2/24 dev veth-red

ip netns exec red ip link set veth-red up

ip netns exec blue ip addr add 192.168.100.3/24 dev veth-blue

ip netns exec blue ip link set veth-blue up
```

```bash
# ip netns exec red ip addr show
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
13: veth-red@if12: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether ea:91:0b:88:87:88 brd ff:ff:ff:ff:ff:ff link-netnsid 1
    inet 192.168.100.2/24 scope global veth-red
       valid_lft forever preferred_lft forever
    inet6 fe80::e891:bff:fe88:8788/64 scope link
       valid_lft forever preferred_lft forever

# ip netns exec blue ip addr show
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
12: veth-blue@if13: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether b6:1c:3c:66:c7:98 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 192.168.100.3/24 scope global veth-blue
       valid_lft forever preferred_lft forever
    inet6 fe80::b41c:3cff:fe66:c798/64 scope link
       valid_lft forever preferred_lft forever
```

### Verify
```bash
# ip netns exec red ping -c1 192.168.100.3
PING 192.168.100.3 (192.168.100.3) 56(84) bytes of data.
64 bytes from 192.168.100.3: icmp_seq=1 ttl=64 time=0.042 ms

--- 192.168.100.3 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.042/0.042/0.042/0.000 ms

# ip netns exec blue ping -c1 192.168.100.2
PING 192.168.100.2 (192.168.100.2) 56(84) bytes of data.
64 bytes from 192.168.100.2: icmp_seq=1 ttl=64 time=0.030 ms

--- 192.168.100.2 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.030/0.030/0.030/0.000 ms
```

### Clean-up
```bash
ip netns exec red ip link delete veth-red
```
NOTE: delete veth `veth-red`, `veth-blue` will be delete automatically as they are a pair.

```bash
# ip netns exec red ip link show
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00

# ip netns exec blue ip link show
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
```

## Connect multi-namespaces
### Create bridge / veth pairs
```bash
ip netns add orange

ip link add cnio0 type bridge

ip link add veth-red type veth peer name veth-red-br
ip link add veth-blue type veth peer name veth-blue-br
ip link add veth-orange type veth peer name veth-orange-br
```

```bash
# ip link show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
    link/ether fa:16:3e:ef:1f:5f brd ff:ff:ff:ff:ff:ff
14: cnio0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether 9a:e4:dc:e1:b9:76 brd ff:ff:ff:ff:ff:ff
15: veth-red-br@veth-red: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether c2:61:55:28:45:75 brd ff:ff:ff:ff:ff:ff
16: veth-red@veth-red-br: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether d2:6f:1a:06:2c:79 brd ff:ff:ff:ff:ff:ff
17: veth-blue-br@veth-blue: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether 56:0b:d2:51:03:98 brd ff:ff:ff:ff:ff:ff
18: veth-blue@veth-blue-br: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether 4e:bb:69:d9:cf:6e brd ff:ff:ff:ff:ff:ff
19: veth-orange-br@veth-orange: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether 92:f5:6f:0e:85:82 brd ff:ff:ff:ff:ff:ff
20: veth-orange@veth-orange-br: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether 1e:03:95:d7:43:4d brd ff:ff:ff:ff:ff:ff
```

### Attach veth to namespaces and bridge
```bash
ip link set veth-red netns red
ip link set veth-blue netns blue
ip link set veth-orange netns orange

ip link set veth-red-br master cnio0
ip link set veth-blue-br master cnio0
ip link set veth-orange-br master cnio0
```

```
# ip link show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
    link/ether fa:16:3e:ef:1f:5f brd ff:ff:ff:ff:ff:ff
14: cnio0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether 56:0b:d2:51:03:98 brd ff:ff:ff:ff:ff:ff
15: veth-red-br@if16: <BROADCAST,MULTICAST> mtu 1500 qdisc noop master cnio0 state DOWN mode DEFAULT group default qlen 1000
    link/ether c2:61:55:28:45:75 brd ff:ff:ff:ff:ff:ff link-netnsid 0
17: veth-blue-br@if18: <BROADCAST,MULTICAST> mtu 1500 qdisc noop master cnio0 state DOWN mode DEFAULT group default qlen 1000
    link/ether 56:0b:d2:51:03:98 brd ff:ff:ff:ff:ff:ff link-netnsid 1
19: veth-orange-br@if20: <BROADCAST,MULTICAST> mtu 1500 qdisc noop master cnio0 state DOWN mode DEFAULT group default qlen 1000
    link/ether 92:f5:6f:0e:85:82 brd ff:ff:ff:ff:ff:ff link-netnsid 2


# ip netns exec red ip link show
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
16: veth-red@if15: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether d2:6f:1a:06:2c:79 brd ff:ff:ff:ff:ff:ff link-netnsid 0

# ip netns exec blue ip link show
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
18: veth-blue@if17: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether 4e:bb:69:d9:cf:6e brd ff:ff:ff:ff:ff:ff link-netnsid 1

# ip netns exec orange ip link show
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
20: veth-orange@if19: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether 1e:03:95:d7:43:4d brd ff:ff:ff:ff:ff:ff link-netnsid 0
```

### IP config
```bash
ip netns exec red ip addr add 192.168.100.2/24 dev veth-red
ip netns exec red ip link set up veth-red
ip link set up veth-red-br

ip netns exec blue ip addr add 192.168.100.3/24 dev veth-blue
ip netns exec blue ip link set up veth-blue
ip link set up veth-blue-br

ip netns exec orange ip addr add 192.168.100.4/24 dev veth-orange
ip netns exec orange ip link set up veth-orange
ip link set up veth-orange-br

ip addr add 192.168.100.1/24 dev cnio0
ip link set up cnio0

sysctl -w net.ipv4.ip_forward=1
```

### Internet connectiion config
```bash
ip netns exec red route add default gw 192.168.100.1
ip netns exec blue route add default gw 192.168.100.1
ip netns exec orange route add default gw 192.168.100.1

iptables -t nat -A POSTROUTING -s 192.168.100.0/24 -j MASQUERADE
```

```bash
# ip netns exec red ping -c1 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=111 time=9.36 ms

--- 8.8.8.8 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 9.364/9.364/9.364/0.000 ms
```

### Verify
```bash
# ip netns exec red ping -c1 192.168.100.1
PING 192.168.100.1 (192.168.100.1) 56(84) bytes of data.
64 bytes from 192.168.100.1: icmp_seq=1 ttl=64 time=0.053 ms

--- 192.168.100.1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.053/0.053/0.053/0.000 ms

# ip netns exec red ping -c1 192.168.100.3
PING 192.168.100.3 (192.168.100.3) 56(84) bytes of data.
64 bytes from 192.168.100.3: icmp_seq=1 ttl=64 time=0.083 ms

--- 192.168.100.3 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.083/0.083/0.083/0.000 ms

# ip netns exec red ping -c1 192.168.100.4
PING 192.168.100.4 (192.168.100.4) 56(84) bytes of data.
64 bytes from 192.168.100.4: icmp_seq=1 ttl=64 time=0.077 ms

--- 192.168.100.4 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.077/0.077/0.077/0.000 ms
```

### Check veth pair info
```bash
# ip netns exec red ethtool -S veth-red
NIC statistics:
     peer_ifindex: 15
```
Peer interface for `veth-red` should be an interface index on `15`
REF: [man 4 veth](https://man7.org/linux/man-pages/man4/veth.4.html)

```bash
# ip link show | grep ^15
15: veth-red-br@if16: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master cnio0 state UP mode DEFAULT group default qlen 1000

# ip link show | grep ^15
15: veth-red-br@if16: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master cnio0 state UP mode DEFAULT group default qlen 1000

# ethtool -S veth-red-br
NIC statistics:
     peer_ifindex: 16

# ip netns exec red ip link show
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
16: veth-red@if15: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default qlen 1000
    link/ether d2:6f:1a:06:2c:79 brd ff:ff:ff:ff:ff:ff link-netnsid 0
```

## Kubernetes
### List all interfaces with type `veth`
```bash
# ip link show type veth
4: veth363800d5@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master cnio0 state UP mode DEFAULT group default
    link/ether 56:12:eb:6c:ac:42 brd ff:ff:ff:ff:ff:ff link-netnsid 0
5: vethc9051bae@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master cnio0 state UP mode DEFAULT group default
    link/ether 2e:93:67:3d:b0:52 brd ff:ff:ff:ff:ff:ff link-netnsid 1
```
Interface `veth363800d5` is connected with network namespace id `0`
Interface `vethc9051bae` is connected with network namespace id `1`

```bash
$ sudo ethtool -S vethc9051bae
NIC statistics:
     peer_ifindex: 2
```

### List all network namespaces
```bash
# ip netns list
cni-5a457186-93e6-ad40-54b3-2310eafdf4f8 (id: 1)
cni-dbc2223b-c0a9-90ad-0c29-6e7bc8b5f340 (id: 0)
```

```bash
# lsns -t net
        NS TYPE NPROCS   PID USER  COMMAND
4026531956 net     107     1 root  /usr/lib/systemd/systemd --switched-root --system --deserialize 21
4026532180 net       2  2196 65535 /pause
4026532264 net       2  2298 65535 /pause
```

### List links inside network namespaces
```bash
# ip -n cni-5a457186-93e6-ad40-54b3-2310eafdf4f8 link show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0@if5: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default
    link/ether 6e:d0:00:9e:25:e6 brd ff:ff:ff:ff:ff:ff link-netnsid 0
```

```bash
# nsenter -t 2298 -n ip link show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0@if5: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default
    link/ether 6e:d0:00:9e:25:e6 brd ff:ff:ff:ff:ff:ff link-netnsid 0
```

So `vethc9051bae` is paired with `eth0` inside network namespace `cni-5a457186-93e6-ad40-54b3-2310eafdf4f8`
