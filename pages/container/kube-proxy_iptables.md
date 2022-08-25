---
title: Kube-Proxy IPTABLES
tags: [container]
keywords: kubernetes, service, iptables
last_updated: Jul 8, 2022
summary: "how kubernetes services implemented with iptables "
sidebar: mydoc_sidebar
permalink: kube-proxy_iptables.html
folder: Container
---

# Kube-Proxy IPTABLES

==================

## Output
### Cluster IP svc
#### IPTABLES
![kubernetes-svc-clusterip](images/container/kubernetes-svc-clusterip.jpg)

1. chain `PREROUTING` in table `nat` 
```bash
$ sudo iptables -t nat -L PREROUTING -vn
Chain PREROUTING (policy ACCEPT 1 packets, 60 bytes)
 pkts bytes target     prot opt in     out     source               destination
   54  3657 KUBE-SERVICES  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* kubernetes service portals */

$ grep '\-A PREROUTING' /tmp/iptables-save
-A PREROUTING -m comment --comment "kubernetes service portals" -j KUBE-SERVICES
```

2. chain `KUBE-SERVICES` in table `nat` 
```bash
$ sudo iptables -t nat -L KUBE-SERVICES  -vn
Chain KUBE-SERVICES (2 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 KUBE-SVC-NPX46M4PTMTKRN6Y  tcp  --  *      *       0.0.0.0/0            10.32.0.1            /* default/kubernetes:https cluster IP */ tcp dpt:443
    0     0 KUBE-SVC-ERIFXISQEP7F7OF4  tcp  --  *      *       0.0.0.0/0            10.32.0.10           /* kube-system/kube-dns:dns-tcp cluster IP */ tcp dpt:53
    0     0 KUBE-SVC-TCOU7JCQXEZGVUNU  udp  --  *      *       0.0.0.0/0            10.32.0.10           /* kube-system/kube-dns:dns cluster IP */ udp dpt:53
    0     0 KUBE-SVC-JD5MR3NA4I4DYORP  tcp  --  *      *       0.0.0.0/0            10.32.0.10           /* kube-system/kube-dns:metrics cluster IP */ tcp dpt:9153
    4   240 KUBE-NODEPORTS  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* kubernetes service nodeports; NOTE: this must be the last rule in this chain */ ADDRTYPE match dst-type LOCAL

$ grep '\-A KUBE-SERVICES' /tmp/iptables-save
-A KUBE-SERVICES -d 10.32.0.1/32 -p tcp -m comment --comment "default/kubernetes:https cluster IP" -m tcp --dport 443 -j KUBE-SVC-NPX46M4PTMTKRN6Y
-A KUBE-SERVICES -d 10.32.0.10/32 -p tcp -m comment --comment "kube-system/kube-dns:dns-tcp cluster IP" -m tcp --dport 53 -j KUBE-SVC-ERIFXISQEP7F7OF4
-A KUBE-SERVICES -d 10.32.0.10/32 -p udp -m comment --comment "kube-system/kube-dns:dns cluster IP" -m udp --dport 53 -j KUBE-SVC-TCOU7JCQXEZGVUNU
-A KUBE-SERVICES -d 10.32.0.10/32 -p tcp -m comment --comment "kube-system/kube-dns:metrics cluster IP" -m tcp --dport 9153 -j KUBE-SVC-JD5MR3NA4I4DYORP
-A KUBE-SERVICES -m comment --comment "kubernetes service nodeports; NOTE: this must be the last rule in this chain" -m addrtype --dst-type LOCAL -j KUBE-NODEPORTS
```

3. chain `KUBE-SVC-TCOU7JCQXEZGVUNU` in table `nat` 
```bash
$ sudo iptables -t nat -L KUBE-SVC-TCOU7JCQXEZGVUNU -vn
Chain KUBE-SVC-TCOU7JCQXEZGVUNU (1 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 KUBE-MARK-MASQ  udp  --  *      *      !10.64.1.0/24         10.32.0.10           /* kube-system/kube-dns:dns cluster IP */ udp dpt:53
    0     0 KUBE-SEP-TYGHG4DTIAC24P3K  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* kube-system/kube-dns:dns */

$ grep '\-A KUBE-SVC-TCOU7JCQXEZGVUNU' /tmp/iptables-save
-A KUBE-SVC-TCOU7JCQXEZGVUNU ! -s 10.64.1.0/24 -d 10.32.0.10/32 -p udp -m comment --comment "kube-system/kube-dns:dns cluster IP" -m udp --dport 53 -j KUBE-MARK-MASQ
-A KUBE-SVC-TCOU7JCQXEZGVUNU -m comment --comment "kube-system/kube-dns:dns" -j KUBE-SEP-TYGHG4DTIAC24P3K
```

4. chain `KUBE-MARK-MASQ` in table `nat` 
```bash
$ sudo iptables -t nat -L KUBE-MARK-MASQ -vn
Chain KUBE-MARK-MASQ (8 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 MARK       all  --  *      *       0.0.0.0/0            0.0.0.0/0            MARK or 0x4000

$ grep '\-A KUBE-MARK-MASQ' /tmp/iptables-save
-A KUBE-MARK-MASQ -j MARK --set-xmark 0x4000/0x4000
```
Purpose: mark set in this step will be used during `POSTROUTING`.

5. chain `KUBE-SEP-TYGHG4DTIAC24P3K` in table `nat` 
```bash
$ sudo iptables -t nat -L KUBE-SEP-TYGHG4DTIAC24P3K -vn
Chain KUBE-SEP-TYGHG4DTIAC24P3K (1 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 KUBE-MARK-MASQ  all  --  *      *       10.64.1.7            0.0.0.0/0            /* kube-system/kube-dns:dns */
    0     0 DNAT       udp  --  *      *       0.0.0.0/0            0.0.0.0/0            /* kube-system/kube-dns:dns */ udp to:10.64.1.7:53

$ grep '\-A KUBE-SEP-TYGHG4DTIAC24P3K' /tmp/iptables-save
-A KUBE-SEP-TYGHG4DTIAC24P3K -s 10.64.1.7/32 -m comment --comment "kube-system/kube-dns:dns" -j KUBE-MARK-MASQ
-A KUBE-SEP-TYGHG4DTIAC24P3K -p udp -m comment --comment "kube-system/kube-dns:dns" -m udp -j DNAT --to-destination 10.64.1.7:53
```

#### TCPDUMP
From `tcpdump`, src ip is `10.64.1.1` and dst ip is `10.64.1.7`
```bash
$ sudo tshark -r dns.pcap frame.number eq 1
Running as user "root" and group "root". This could be dangerous.
  1          0    10.64.1.1 -> 10.64.1.7    DNS 90 Standard query 0xb710  A www.microsoft.com

$ sudo tshark -r dns.pcap frame.number eq 1 -T fields -e ip.src -e udp.srcport -e ip.dst -e udp.dstport  -E separator=, -E quote=d
Running as user "root" and group "root". This could be dangerous.
"10.64.1.1","44560","10.64.1.7","53
```

#### CONNTRACK
`conntrock -L` result
Both src ip and dst ip has been NAT as shown in tcpdump result. 
```bash
$ grep 44560 /tmp/conntrack
udp      17 21 src=172.16.1.35 dst=10.32.0.10 sport=44560 dport=53 src=10.64.1.7 dst=10.64.1.1 sport=53 dport=44560 mark=0 use=1
```

### NodePort IP svc
#### IPTABLES
![kubernetes-svc-nodeport](images/container/kubernetes-svc-nodeport.jpg)

1. chain `PREROUTING` in table `nat` 
```bash
$ sudo iptables -t nat -L PREROUTING -v -n
Chain PREROUTING (policy ACCEPT 2 packets, 120 bytes)
 pkts bytes target     prot opt in     out     source               destination
   67  4531 KUBE-SERVICES  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* kubernetes service portals */

$ grep '\-A PREROUTING' /tmp/iptables-save-svc
-A PREROUTING -m comment --comment "kubernetes service portals" -j KUBE-SERVICES
```

2. chain `KUBE-SERVICES` in table `nat` 
```bash
$ sudo iptables -t nat -L KUBE-SERVICES -v -n
Chain KUBE-SERVICES (2 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 KUBE-SVC-ERIFXISQEP7F7OF4  tcp  --  *      *       0.0.0.0/0            10.32.0.10           /* kube-system/kube-dns:dns-tcp cluster IP */ tcp dpt:53
    0     0 KUBE-SVC-TCOU7JCQXEZGVUNU  udp  --  *      *       0.0.0.0/0            10.32.0.10           /* kube-system/kube-dns:dns cluster IP */ udp dpt:53
    0     0 KUBE-SVC-JD5MR3NA4I4DYORP  tcp  --  *      *       0.0.0.0/0            10.32.0.10           /* kube-system/kube-dns:metrics cluster IP */ tcp dpt:9153
    0     0 KUBE-SVC-NPX46M4PTMTKRN6Y  tcp  --  *      *       0.0.0.0/0            10.32.0.1            /* default/kubernetes:https cluster IP */ tcp dpt:443
    0     0 KUBE-SVC-YVE4DVDYZJRPV46I  tcp  --  *      *       0.0.0.0/0            10.32.0.159          /* default/web-svc:nginx-svc-port cluster IP */ tcp dpt:8080
   74  4440 KUBE-NODEPORTS  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* kubernetes service nodeports; NOTE: this must be the last rule in this chain */ ADDRTYPE match dst-type LOCAL

$ grep '\-A KUBE-SERVICES' /tmp/iptables-save-svc
-A KUBE-SERVICES -d 10.32.0.10/32 -p udp -m comment --comment "kube-system/kube-dns:dns cluster IP" -m udp --dport 53 -j KUBE-SVC-TCOU7JCQXEZGVUNU
-A KUBE-SERVICES -d 10.32.0.10/32 -p tcp -m comment --comment "kube-system/kube-dns:metrics cluster IP" -m tcp --dport 9153 -j KUBE-SVC-JD5MR3NA4I4DYORP
-A KUBE-SERVICES -d 10.32.0.1/32 -p tcp -m comment --comment "default/kubernetes:https cluster IP" -m tcp --dport 443 -j KUBE-SVC-NPX46M4PTMTKRN6Y
-A KUBE-SERVICES -d 10.32.0.159/32 -p tcp -m comment --comment "default/web-svc:nginx-svc-port cluster IP" -m tcp --dport 8080 -j KUBE-SVC-YVE4DVDYZJRPV46I
-A KUBE-SERVICES -d 10.32.0.10/32 -p tcp -m comment --comment "kube-system/kube-dns:dns-tcp cluster IP" -m tcp --dport 53 -j KUBE-SVC-ERIFXISQEP7F7OF4
-A KUBE-SERVICES -m comment --comment "kubernetes service nodeports; NOTE: this must be the last rule in this chain" -m addrtype --dst-type LOCAL -j KUBE-NODEPORTS
```

3. chain `KUBE-NODEPORTS` in table `nat` 
```bash
$ sudo iptables -t nat -L KUBE-NODEPORTS -v -n
Chain KUBE-NODEPORTS (1 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 KUBE-SVC-YVE4DVDYZJRPV46I  tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            /* default/web-svc:nginx-svc-port */ tcp dpt:30080

$ grep '\-A KUBE-NODEPORTS' /tmp/iptables-save-svc
-A KUBE-NODEPORTS -p tcp -m comment --comment "default/web-svc:nginx-svc-port" -m tcp --dport 30080 -j KUBE-SVC-YVE4DVDYZJRPV46I
```

4. chain `KUBE-SVC-YVE4DVDYZJRPV46I` in table `nat` 
```bash
$ sudo iptables -t nat -L KUBE-SVC-YVE4DVDYZJRPV46I -v -n
Chain KUBE-SVC-YVE4DVDYZJRPV46I (2 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 KUBE-MARK-MASQ  tcp  --  *      *      !10.64.1.0/24         10.32.0.159          /* default/web-svc:nginx-svc-port cluster IP */ tcp dpt:8080
    0     0 KUBE-MARK-MASQ  tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            /* default/web-svc:nginx-svc-port */ tcp dpt:30080
    0     0 KUBE-SEP-CC3QGOI23D5U3CR7  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* default/web-svc:nginx-svc-port */

$ grep '\-A KUBE-SVC-YVE4DVDYZJRPV46I' /tmp/iptables-save-svc
-A KUBE-SVC-YVE4DVDYZJRPV46I ! -s 10.64.1.0/24 -d 10.32.0.159/32 -p tcp -m comment --comment "default/web-svc:nginx-svc-port cluster IP" -m tcp --dport 8080 -j KUBE-MARK-MASQ
-A KUBE-SVC-YVE4DVDYZJRPV46I -p tcp -m comment --comment "default/web-svc:nginx-svc-port" -m tcp --dport 30080 -j KUBE-MARK-MASQ
-A KUBE-SVC-YVE4DVDYZJRPV46I -m comment --comment "default/web-svc:nginx-svc-port" -j KUBE-SEP-CC3QGOI23D5U3CR7
```
`Rule 1` is for traffic NOT from `pod_network` and to `cluster_svc_ip`:`port` 

5. chain `KUBE-MARK-MASQ` in table `nat` 
```bash
$ sudo iptables -t nat -L KUBE-MARK-MASQ -v -n
Chain KUBE-MARK-MASQ (11 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 MARK       all  --  *      *       0.0.0.0/0            0.0.0.0/0            MARK or 0x4000

$ grep '\-A KUBE-MARK-MASQ' /tmp/iptables-save-svc
-A KUBE-MARK-MASQ -j MARK --set-xmark 0x4000/0x4000
```
Purpose: mark set in this step will be used during `POSTROUTING`.

6. chain `KUBE-SEP-CC3QGOI23D5U3CR7` in table `nat` 
```bash
$ sudo iptables -t nat -L KUBE-SEP-CC3QGOI23D5U3CR7 -v -n
Chain KUBE-SEP-CC3QGOI23D5U3CR7 (1 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 KUBE-MARK-MASQ  all  --  *      *       10.64.1.13           0.0.0.0/0            /* default/web-svc:nginx-svc-port */
    0     0 DNAT       tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            /* default/web-svc:nginx-svc-port */ tcp to:10.64.1.13:80

$ grep '\-A KUBE-SEP-CC3QGOI23D5U3CR7' /tmp/iptables-save-svc
-A KUBE-SEP-CC3QGOI23D5U3CR7 -s 10.64.1.13/32 -m comment --comment "default/web-svc:nginx-svc-port" -j KUBE-MARK-MASQ
-A KUBE-SEP-CC3QGOI23D5U3CR7 -p tcp -m comment --comment "default/web-svc:nginx-svc-port" -m tcp -j DNAT --to-destination 10.64.1.13:80
```

#### TCPDUMP
```bash
# tcpdump -i any port 80 -n -e -S -w /tmp/http.pcap

$ sudo tshark -r /tmp/http.pcap frame.number eq 1
Running as user "root" and group "root". This could be dangerous.
  1          0    10.64.1.1 -> 10.64.1.13   TCP 76 35814 > http [SYN] Seq=0 Win=43690 Len=0 MSS=65495 SACK_PERM=1 TSval=690383431 TSecr=0 WS=128

$ sudo tshark -r /tmp/http.pcap frame.number eq 1 -T fields -e ip.src -e tcp.srcport -e ip.dst -e tcp.dstport  -E separator=, -E quote=d
Running as user "root" and group "root". This could be dangerous.
"10.64.1.1","35814","10.64.1.13","80"
```

#### CONNTRCK
```bash
$ sudo conntrack -L | grep 35814
tcp      6 72 TIME_WAIT src=172.16.1.35 dst=172.16.1.35 sport=35814 dport=30080 src=10.64.1.13 dst=10.64.1.1 sport=80 dport=35814 [ASSURED] mark=0 use=1
```

NOTE: 
Troubleshoot IPTABLES via `LOG` module
```bash
sudo iptables -t nat -D KUBE-SVC-YVE4DVDYZJRPV46I -p tcp -j LOG --log-prefix "INPUT packets"
```

{% include links.html %}
