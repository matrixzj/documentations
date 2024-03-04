---
title: Kube-Proxy IPTABLES
tags: [container]
keywords: kubernetes, service, iptables
last_updated: Mar 1, 2024
summary: "how kubernetes services implemented with iptables"
sidebar: mydoc_sidebar
permalink: kube-proxy_iptables.html
folder: Container
---

# Kube-Proxy IPTABLES

==================

## Flow of IPTables 
![IPTables Flow](images/container/iptables.png)

REF: [Netfilter](https://en.wikipedia.org/wiki/Netfilter#)

## General 
* `KUBE-SVC-`	a load balancer, which the main iptables chain for that service, used for dispatching to endpoints when using `Cluster` traffic policy.
* `KUBE-SVL-`	a load balancer, which handles dispatching to local endpoints when using `Local` traffic policy. This chain only exists if the service has `Local` internal or external traffic policy.
* `KUBE-EXT-` implements "short-circuiting" for internally-originated external-destination traffic when using `Local` external traffic policy. It forwards traffic from local sources to the `KUBE-SVC-` chain and traffic from external sources to the `KUBE-SVL-` chain.
* `KUBE-SEP-` a Service EndPoint. It simply does DNAT, replacing service IP:port with pod’s endpoint IP:Port.

## Cluster IP SVC
### Env
```bash
$ kubectl get svc nginx -o yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    app: nginx
  name: nginx
  namespace: default
spec:
  clusterIP: 10.32.0.251
  clusterIPs:
  - 10.32.0.251
  internalTrafficPolicy: Cluster
  ipFamilies:
  - IPv4
  ipFamilyPolicy: SingleStack
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: nginx-pod
  sessionAffinity: None
  type: ClusterIP

$ kubectl get pods -o wide
NAME                     READY   STATUS    RESTARTS   AGE     IP          NODE                              NOMINATED NODE   READINESS GATES
nginx-74b5c74d54-569hj   1/1     Running   0          7d19h   10.64.2.4   ecs-matrix-k8s-cluster-worker02   <none>           <none>
```

### IPTABLES
#### Ingress
`PREROUTING` ==> `KUBE-SERVICE` ==> `KUBE-SVC-2CMXP7HKUVJN7L6M` ==> `KUBE-SEP-YVT6EXXEKT4LDXBC`

#### Egress
`OUTPUT` ==> `KUBE-SERVICE` ==> `KUBE-SVC-2CMXP7HKUVJN7L6M` ==> `KUBE-SEP-YVT6EXXEKT4LDXBC`  
From a node where pod is not running there

#### Rules
* chain `PREROUTING` in table `nat`
  ```bash
  $ sudo iptables -t nat -L PREROUTING -vn
  Chain PREROUTING (policy ACCEPT 16 packets, 3200 bytes)
    pkts bytes target     prot opt in     out     source               destination
  37207 7396K KUBE-SERVICES  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* kubernetes service portals */

  $ sed -n '/*nat/{:a;N;/\*filter/!{ba};p}' /tmp/iptables | grep '\-A PREROUTING'
  -A PREROUTING -m comment --comment "kubernetes service portals" -j KUBE-SERVICES
  ```

* chain `OUTPUT` in table `nat`  
  ```bash
  $ sudo iptables -t nat -L OUTPUT -vn
  Chain OUTPUT (policy ACCEPT 5826 packets, 350K bytes)
  pkts bytes target     prot opt in     out     source               destination
  2054K  123M KUBE-SERVICES  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* kubernetes service portals */

  $ sed -n '/*nat/{:a;N;/\*filter/!{ba};p}' /tmp/iptables | grep '\-A OUTPUT'
  -A OUTPUT -m comment --comment "kubernetes service portals" -j KUBE-SERVICES
  ```

* chain `KUBE-SERVICES` in table `nat` 
  ```bash
  $ sudo iptables -t nat -L KUBE-SERVICES -vn
  Chain KUBE-SERVICES (2 references)
    pkts bytes target     prot opt in     out     source               destination
      2   120 KUBE-SVC-2CMXP7HKUVJN7L6M  tcp  --  *      *       0.0.0.0/0            10.32.0.251          /* default/nginx cluster IP */ tcp dpt:80
      0     0 KUBE-SVC-NPX46M4PTMTKRN6Y  tcp  --  *      *       0.0.0.0/0            10.32.0.1            /* default/kubernetes:https cluster IP */ tcp dpt:443
      0     0 KUBE-SVC-TCOU7JCQXEZGVUNU  udp  --  *      *       0.0.0.0/0            10.32.0.10           /* kube-system/kube-dns:dns cluster IP */ udp dpt:53
      0     0 KUBE-SVC-ERIFXISQEP7F7OF4  tcp  --  *      *       0.0.0.0/0            10.32.0.10           /* kube-system/kube-dns:dns-tcp cluster IP */ tcp dpt:53
      0     0 KUBE-SVC-JD5MR3NA4I4DYORP  tcp  --  *      *       0.0.0.0/0            10.32.0.10           /* kube-system/kube-dns:metrics cluster IP */ tcp dpt:9153
    3858  231K KUBE-NODEPORTS  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* kubernetes service nodeports; NOTE: this must be the last rule in this chain */ ADDRTYPE match dst-type LOCAL

  $ grep '\-A KUBE-SERVICES' /tmp/iptables
  -A KUBE-SERVICES -d 10.32.0.251/32 -p tcp -m comment --comment "default/nginx cluster IP" -m tcp --dport 80 -j KUBE-SVC-2CMXP7HKUVJN7L6M
  -A KUBE-SERVICES -d 10.32.0.1/32 -p tcp -m comment --comment "default/kubernetes:https cluster IP" -m tcp --dport 443 -j KUBE-SVC-NPX46M4PTMTKRN6Y
  -A KUBE-SERVICES -d 10.32.0.10/32 -p udp -m comment --comment "kube-system/kube-dns:dns cluster IP" -m udp --dport 53 -j KUBE-SVC-TCOU7JCQXEZGVUNU
  -A KUBE-SERVICES -d 10.32.0.10/32 -p tcp -m comment --comment "kube-system/kube-dns:dns-tcp cluster IP" -m tcp --dport 53 -j KUBE-SVC-ERIFXISQEP7F7OF4
  -A KUBE-SERVICES -d 10.32.0.10/32 -p tcp -m comment --comment "kube-system/kube-dns:metrics cluster IP" -m tcp --dport 9153 -j KUBE-SVC-JD5MR3NA4I4DYORP
  -A KUBE-SERVICES -m comment --comment "kubernetes service nodeports; NOTE: this must be the last rule in this chain" -m addrtype --dst-type LOCAL -j KUBE-NODEPORTS
  ```

* chain `KUBE-SVC-2CMXP7HKUVJN7L6M` in table `nat` 
  ```bash
  $ sudo iptables -t nat -L KUBE-SVC-2CMXP7HKUVJN7L6M -vn
  Chain KUBE-SVC-2CMXP7HKUVJN7L6M (1 references)
    pkts bytes target     prot opt in     out     source               destination
      2   120 KUBE-SEP-YVT6EXXEKT4LDXBC  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* default/nginx -> 10.64.2.4:80 */

  $ grep '\-A KUBE-SVC-2CMXP7HKUVJN7L6M' /tmp/iptables
  -A KUBE-SVC-2CMXP7HKUVJN7L6M -m comment --comment "default/nginx -> 10.64.2.4:80" -j KUBE-SEP-YVT6EXXEKT4LDXBC
  ```

* chain `KUBE-SEP-YVT6EXXEKT4LDXBC` in table `nat` 
  ```bash
  $ sudo iptables -t nat -L KUBE-SEP-YVT6EXXEKT4LDXBC -vn
  Chain KUBE-SEP-YVT6EXXEKT4LDXBC (1 references)
    pkts bytes target     prot opt in     out     source               destination
      0     0 KUBE-MARK-MASQ  all  --  *      *       10.64.2.4            0.0.0.0/0            /* default/nginx */
      2   120 DNAT       tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            /* default/nginx */ tcp to:10.64.2.4:80

  $ grep '\-A KUBE-SEP-YVT6EXXEKT4LDXBC' /tmp/iptables
  -A KUBE-SEP-YVT6EXXEKT4LDXBC -s 10.64.2.4/32 -m comment --comment "default/nginx" -j KUBE-MARK-MASQ
  -A KUBE-SEP-YVT6EXXEKT4LDXBC -p tcp -m comment --comment "default/nginx" -m tcp -j DNAT --to-destination 10.64.2.4:80
  ```

### TCPDUMP
From `tcpdump`, src ip is `172.16.1.152` and dst ip is `10.64.2.4`
```bash
$ tshark -r /tmp/http.pcap tcp.stream==4 -n
 23          4 172.16.1.152 -> 10.64.2.4    TCP 74 45088 > 80 [SYN] Seq=0 Win=64240 Len=0 MSS=1460 SACK_PERM=1 TSval=445053550 TSecr=0 WS=128
 24          4    10.64.2.4 -> 172.16.1.152 TCP 74 80 > 45088 [SYN, ACK] Seq=0 Ack=1 Win=65160 Len=0 MSS=1460 SACK_PERM=1 TSval=480000512 TSecr=445053550 WS=128
 25          4 172.16.1.152 -> 10.64.2.4    TCP 66 45088 > 80 [ACK] Seq=1 Ack=1 Win=64256 Len=0 TSval=445053550 TSecr=480000512
 26          4 172.16.1.152 -> 10.64.2.4    HTTP 141 GET / HTTP/1.1
 27          4    10.64.2.4 -> 172.16.1.152 TCP 66 80 > 45088 [ACK] Seq=1 Ack=76 Win=65152 Len=0 TSval=480000512 TSecr=445053550
 28          4    10.64.2.4 -> 172.16.1.152 TCP 302 [TCP segment of a reassembled PDU]
 29          4 172.16.1.152 -> 10.64.2.4    TCP 66 45088 > 80 [ACK] Seq=76 Ack=237 Win=64128 Len=0 TSval=445053550 TSecr=480000512
 30          4    10.64.2.4 -> 172.16.1.152 HTTP 85 HTTP/1.1 200 OK  (text/html)
 31          4 172.16.1.152 -> 10.64.2.4    TCP 66 45088 > 80 [ACK] Seq=76 Ack=256 Win=64128 Len=0 TSval=445053550 TSecr=480000513
 33          4 172.16.1.152 -> 10.64.2.4    TCP 66 45088 > 80 [FIN, ACK] Seq=76 Ack=256 Win=64128 Len=0 TSval=445053550 TSecr=480000513
 35          4    10.64.2.4 -> 172.16.1.152 TCP 66 80 > 45088 [FIN, ACK] Seq=256 Ack=77 Win=65152 Len=0 TSval=480000513 TSecr=445053550
 36          4 172.16.1.152 -> 10.64.2.4    TCP 66 45088 > 80 [ACK] Seq=77 Ack=257 Win=64128 Len=0 TSval=445053551 TSecr=480000513

$ tshark -r /tmp/http.pcap frame.number eq 24 -T fields -e ip.src -e tcp.srcport -e ip.dst -e tcp.dstport  -E separator=, -E quote=d
"10.64.2.4","80","172.16.1.152","45088"
```

### CONNTRACK
`conntrock -L` result or check `/proc/net/nf_conntrack`
Both src ip and dst ip has been NAT as shown in tcpdump result. 
```bash
$ grep 'dport=80 ' /tmp/conntrack
tcp      6 118 TIME_WAIT src=172.16.1.152 dst=10.32.0.251 sport=43400 dport=80 src=10.64.2.4 dst=172.16.1.152 sport=80 dport=43400 [ASSURED] mark=0 use=1
```

## NodePort SVC with `Cluster` Traffic Policy
### Env
```bash
apiVersion: v1
kind: Service
metadata:
  labels:
    app: nginx
  name: nginx
  namespace: default
spec:
  clusterIP: 10.32.0.61
  clusterIPs:
  - 10.32.0.61
  externalTrafficPolicy: Cluster
  internalTrafficPolicy: Cluster
  ipFamilies:
  - IPv4
  ipFamilyPolicy: SingleStack
  ports:
  - nodePort: 30783
    port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: nginx-pod
  sessionAffinity: None
  type: NodePort
```

### IPTABLES
#### Ingress 
`INPUT` ==> `KUBE-NODEPORTS` ==> `KUBE-EXT-2CMXP7HKUVJN7L6M` ==> `KUBE-MARK-MASQ` ==> `KUBE-SVC-2CMXP7HKUVJN7L6M` ==> `KUBE-SEP-YVT6EXXEKT4LDXBC`

1. chain `INPUT` in table `filter` 
    ```bash
    $ sudo iptables -t filter -L INPUT -vn
    Chain INPUT (policy ACCEPT 230K packets, 36M bytes)
    pkts bytes target     prot opt in     out     source               destination
    901K   54M KUBE-PROXY-FIREWALL  all  --  *      *       0.0.0.0/0            0.0.0.0/0            ctstate NEW /* kubernetes load balancer firewall */
      92M   15G KUBE-NODEPORTS  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* kubernetes health check service ports */
    901K   54M KUBE-EXTERNAL-SERVICES  all  --  *      *       0.0.0.0/0            0.0.0.0/0            ctstate NEW /* kubernetes externally-visible service portals */
      92M   15G KUBE-FIREWALL  all  --  *      *       0.0.0.0/0            0.0.0.0/0

    $ grep '\-A INPUT' /tmp/iptables
    -A INPUT -m conntrack --ctstate NEW -m comment --comment "kubernetes load balancer firewall" -j KUBE-PROXY-FIREWALL
    -A INPUT -m comment --comment "kubernetes health check service ports" -j KUBE-NODEPORTS
    -A INPUT -m conntrack --ctstate NEW -m comment --comment "kubernetes externally-visible service portals" -j KUBE-EXTERNAL-SERVICES
    -A INPUT -j KUBE-FIREWALL
    ```

2. chain `KUBE-NODEPORTS` in table `nat`
    ```bash
    $ sudo iptables -t nat -L KUBE-NODEPORTS -vn
    Chain KUBE-NODEPORTS (1 references)
    pkts bytes target     prot opt in     out     source               destination
        2   120 KUBE-EXT-2CMXP7HKUVJN7L6M  tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            /* default/nginx */ tcp dpt:30783

    $ grep '\-A KUBE-NODEPORTS' /tmp/iptables
    -A KUBE-NODEPORTS -p tcp -m comment --comment "default/nginx" -m tcp --dport 30783 -j KUBE-EXT-2CMXP7HKUVJN7L6M
    ```

3. chain `KUBE-EXT-2CMXP7HKUVJN7L6M` in table `nat` 
    ```bash
    $ sudo iptables -t nat -L KUBE-EXT-2CMXP7HKUVJN7L6M -vn
    Chain KUBE-EXT-2CMXP7HKUVJN7L6M (1 references)
    pkts bytes target     prot opt in     out     source               destination
        1    60 KUBE-MARK-MASQ  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* masquerade traffic for default/nginx external destinations */
        1    60 KUBE-SVC-2CMXP7HKUVJN7L6M  all  --  *      *       0.0.0.0/0            0.0.0.0/0

    $ grep '\-A KUBE-EXT-2CMXP7HKUVJN7L6M' /tmp/iptables
    -A KUBE-EXT-2CMXP7HKUVJN7L6M -m comment --comment "masquerade traffic for default/nginx external destinations" -j KUBE-MARK-MASQ
    -A KUBE-EXT-2CMXP7HKUVJN7L6M -j KUBE-SVC-2CMXP7HKUVJN7L6M
    ```
    `Rule 1` is for traffic NOT from `pod_network` and to `cluster_svc_ip`:`port` 

4. chain `KUBE-MARK-MASQ` in table `nat` 
    ```bash
    $ sudo iptables -t nat -L KUBE-MARK-MASQ -vn
    Chain KUBE-MARK-MASQ (9 references)
    pkts bytes target     prot opt in     out     source               destination
        1    60 MARK       all  --  *      *       0.0.0.0/0            0.0.0.0/0            MARK or 0x4000

    $ grep '\-A KUBE-MARK-MASQ' /tmp/iptables
    -A KUBE-MARK-MASQ -j MARK --set-xmark 0x4000/0x4000
    ```
    Purpose: mark set in this step will be used during `POSTROUTING`.

5. chain `KUBE-SVC-2CMXP7HKUVJN7L6M` in table `nat` 
    ```bash
    $ sudo iptables -t nat -L KUBE-SVC-2CMXP7HKUVJN7L6M -vn
    Chain KUBE-SVC-2CMXP7HKUVJN7L6M (2 references)
    pkts bytes target     prot opt in     out     source               destination
        1    60 KUBE-SEP-YVT6EXXEKT4LDXBC  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* default/nginx -> 10.64.2.4:80 */

    $ grep '\-A KUBE-SVC-2CMXP7HKUVJN7L6M' /tmp/iptables
    -A KUBE-SVC-2CMXP7HKUVJN7L6M -m comment --comment "default/nginx -> 10.64.2.4:80" -j KUBE-SEP-YVT6EXXEKT4LDXBC
    ```

6. chain `KUBE-SEP-YVT6EXXEKT4LDXBC` in table `nat` 
   ```bash
    $ sudo iptables -t nat -L KUBE-SEP-YVT6EXXEKT4LDXBC -vn
    Chain KUBE-SEP-YVT6EXXEKT4LDXBC (1 references)
    pkts bytes target     prot opt in     out     source               destination
        0     0 KUBE-MARK-MASQ  all  --  *      *       10.64.2.4            0.0.0.0/0            /* default/nginx */
        1    60 DNAT       tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            /* default/nginx */ tcp to:10.64.2.4:80

    $ grep '\-A KUBE-SEP-YVT6EXXEKT4LDXBC' /tmp/iptables
    -A KUBE-SEP-YVT6EXXEKT4LDXBC -s 10.64.2.4/32 -m comment --comment "default/nginx" -j KUBE-MARK-MASQ
    -A KUBE-SEP-YVT6EXXEKT4LDXBC -p tcp -m comment --comment "default/nginx" -m tcp -j DNAT --to-destination 10.64.2.4:80
    ```

#### Egress
`PREROUTING` ==> `KUBE-SERVICES` ==> `KUBE-NODEPORTS` ==> `KUBE-EXT-2CMXP7HKUVJN7L6M` ==> `KUBE-MARK-MASQ` ==> `KUBE-SVC-2CMXP7HKUVJN7L6M` ==> `KUBE-SEP-YVT6EXXEKT4LDXBC`

1. chain `PREROUTING` in table `nat` 
    ```bash
    $ sudo iptables -t nat -L PREROUTING -vn
    Chain PREROUTING (policy ACCEPT 9 packets, 1100 bytes)
    pkts bytes target     prot opt in     out     source               destination
    21184 4212K KUBE-SERVICES  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* kubernetes service portals */

    $ grep '\-A PREROUTING' /tmp/iptables
    -A PREROUTING -m comment --comment "kubernetes service portals" -j KUBE-SERVICES
    ```

2. chain `KUBE-SERVICES` in table `nat` 
    ```bash
    $ sudo iptables -t nat -L KUBE-SERVICES -vn
    Chain KUBE-SERVICES (2 references)
    pkts bytes target     prot opt in     out     source               destination
        0     0 KUBE-SVC-NPX46M4PTMTKRN6Y  tcp  --  *      *       0.0.0.0/0            10.32.0.1            /* default/kubernetes:https cluster IP */ tcp dpt:443
        0     0 KUBE-SVC-TCOU7JCQXEZGVUNU  udp  --  *      *       0.0.0.0/0            10.32.0.10           /* kube-system/kube-dns:dns cluster IP */ udp dpt:53
        0     0 KUBE-SVC-ERIFXISQEP7F7OF4  tcp  --  *      *       0.0.0.0/0            10.32.0.10           /* kube-system/kube-dns:dns-tcp cluster IP */ tcp dpt:53
        0     0 KUBE-SVC-JD5MR3NA4I4DYORP  tcp  --  *      *       0.0.0.0/0            10.32.0.10           /* kube-system/kube-dns:metrics cluster IP */ tcp dpt:9153
        0     0 KUBE-SVC-2CMXP7HKUVJN7L6M  tcp  --  *      *       0.0.0.0/0            10.32.0.61           /* default/nginx cluster IP */ tcp dpt:80
      366 21960 KUBE-NODEPORTS  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* kubernetes service nodeports; NOTE: this must be the last rule in this chain */ ADDRTYPE match dst-type LOCAL

    $ grep '\-A KUBE-SERVICES' /tmp/iptables
    -A KUBE-SERVICES -d 10.32.0.1/32 -p tcp -m comment --comment "default/kubernetes:https cluster IP" -m tcp --dport 443 -j KUBE-SVC-NPX46M4PTMTKRN6Y
    -A KUBE-SERVICES -d 10.32.0.10/32 -p udp -m comment --comment "kube-system/kube-dns:dns cluster IP" -m udp --dport 53 -j KUBE-SVC-TCOU7JCQXEZGVUNU
    -A KUBE-SERVICES -d 10.32.0.10/32 -p tcp -m comment --comment "kube-system/kube-dns:dns-tcp cluster IP" -m tcp --dport 53 -j KUBE-SVC-ERIFXISQEP7F7OF4
    -A KUBE-SERVICES -d 10.32.0.10/32 -p tcp -m comment --comment "kube-system/kube-dns:metrics cluster IP" -m tcp --dport 9153 -j KUBE-SVC-JD5MR3NA4I4DYORP
    -A KUBE-SERVICES -d 10.32.0.61/32 -p tcp -m comment --comment "default/nginx cluster IP" -m tcp --dport 80 -j KUBE-SVC-2CMXP7HKUVJN7L6M
    -A KUBE-SERVICES -m comment --comment "kubernetes service nodeports; NOTE: this must be the last rule in this chain" -m addrtype --dst-type LOCAL -j KUBE-NODEPORTS
    ```

3. chain `KUBE-NODEPORTS` in table `nat` 
    ```bash
    $ sudo iptables -t nat -L KUBE-NODEPORTS -vn
    Chain KUBE-NODEPORTS (1 references)
    pkts bytes target     prot opt in     out     source               destination
        1    60 KUBE-EXT-2CMXP7HKUVJN7L6M  tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            /* default/nginx */ tcp dpt:30783

    $ grep '\-A KUBE-NODEPORTS' /tmp/iptables
    -A KUBE-NODEPORTS -p tcp -m comment --comment "default/nginx" -m tcp --dport 30783 -j KUBE-EXT-2CMXP7HKUVJN7L6M
    ```

4. chain `KUBE-EXT-2CMXP7HKUVJN7L6M` in table `nat` 
    ```bash
    $ sudo iptables -t nat -L KUBE-EXT-2CMXP7HKUVJN7L6M -vn
    Chain KUBE-EXT-2CMXP7HKUVJN7L6M (1 references)
    pkts bytes target     prot opt in     out     source               destination
        1    60 KUBE-MARK-MASQ  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* masquerade traffic for default/nginx external destinations */
        1    60 KUBE-SVC-2CMXP7HKUVJN7L6M  all  --  *      *       0.0.0.0/0            0.0.0.0/0

    $ grep '\-A KUBE-EXT-2CMXP7HKUVJN7L6M' /tmp/iptables
    -A KUBE-EXT-2CMXP7HKUVJN7L6M -m comment --comment "masquerade traffic for default/nginx external destinations" -j KUBE-MARK-MASQ
    -A KUBE-EXT-2CMXP7HKUVJN7L6M -j KUBE-SVC-2CMXP7HKUVJN7L6M
    ```

5. chain `KUBE-MARK-MASQ` in table `nat` 
    ```bash
    $ sudo iptables -t nat -L KUBE-MARK-MASQ -vn
    Chain KUBE-MARK-MASQ (9 references)
    pkts bytes target     prot opt in     out     source               destination
        1    60 MARK       all  --  *      *       0.0.0.0/0            0.0.0.0/0            MARK or 0x4000

    $ grep '\-A KUBE-MARK-MASQ' /tmp/iptables
    -A KUBE-MARK-MASQ -j MARK --set-xmark 0x4000/0x4000
    ```
    Purpose: mark set in this step will be used during `POSTROUTING`.

6. chain `KUBE-SVC-2CMXP7HKUVJN7L6M` in table `nat` 
    ```bash
    $ sudo iptables -t nat -L KUBE-SVC-2CMXP7HKUVJN7L6M -vn
    Chain KUBE-SVC-2CMXP7HKUVJN7L6M (2 references)
    pkts bytes target     prot opt in     out     source               destination
        1    60 KUBE-SEP-YVT6EXXEKT4LDXBC  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* default/nginx -> 10.64.2.4:80 */

    $ grep '\-A KUBE-SVC-2CMXP7HKUVJN7L6M' /tmp/iptables
    -A KUBE-SVC-2CMXP7HKUVJN7L6M -m comment --comment "default/nginx -> 10.64.2.4:80" -j KUBE-SEP-YVT6EXXEKT4LDXBC
    ```

7. chain `KUBE-SEP-YVT6EXXEKT4LDXBC` in table `nat` 
    ```bash
    $ sudo iptables -t nat -L KUBE-SEP-YVT6EXXEKT4LDXBC -vn
    Chain KUBE-SEP-YVT6EXXEKT4LDXBC (1 references)
    pkts bytes target     prot opt in     out     source               destination
        0     0 KUBE-MARK-MASQ  all  --  *      *       10.64.2.4            0.0.0.0/0            /* default/nginx */
        1    60 DNAT       tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            /* default/nginx */ tcp to:10.64.2.4:80

    $ grep '\-A KUBE-SEP-YVT6EXXEKT4LDXBC' /tmp/iptables
    -A KUBE-SEP-YVT6EXXEKT4LDXBC -s 10.64.2.4/32 -m comment --comment "default/nginx" -j KUBE-MARK-MASQ
    -A KUBE-SEP-YVT6EXXEKT4LDXBC -p tcp -m comment --comment "default/nginx" -m tcp -j DNAT --to-destination 10.64.2.4:80
    ```

### TCPDUMP
Captured on the node where pod is running
```bash
$ sudo tcpdump -i any port 80 -n -e -S -w /tmp/http.pcap

$ tshark -r /tmp/http.pcap frame.number eq 1
  1          0 172.16.1.152 -> 10.64.2.4    TCP 76 6275 > http [SYN] Seq=0 Win=65495 Len=0 MSS=65495 SACK_PERM=1 TSval=1653108361 TSecr=0 WS=128

$ tshark -r /tmp/http.pcap frame.number eq 1 -T fields -e ip.src -e tcp.srcport -e ip.dst -e tcp.dstport  -E separator=, -E quote=d
"172.16.1.152","6275","10.64.2.4","80"
```

### CONNTRCK
```bash
$ sudo conntrack -L  | grep 80
conntrack v1.4.4 (conntrack-tools): 4 flow entries have been shown.
tcp      6 101 TIME_WAIT src=172.16.1.152 dst=10.64.2.4 sport=35739 dport=80 src=10.64.2.4 dst=172.16.1.152 sport=80 dport=35739 [ASSURED] mark=0 use=1
```

## NodePort SVC with `Local` Traffic Policy
### Env
```bash
$ kubectl get svc nginx -o yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    app: nginx
  name: nginx
  namespace: default
spec:
  clusterIP: 10.32.0.61
  clusterIPs:
  - 10.32.0.61
  externalTrafficPolicy: Local
  internalTrafficPolicy: Cluster
  ipFamilies:
  - IPv4
  ipFamilyPolicy: SingleStack
  ports:
  - nodePort: 30783
    port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: nginx-pod
  sessionAffinity: None
  type: NodePort

$ kubectl get pods -o wide
NAME                     READY   STATUS    RESTARTS   AGE     IP          NODE                              NOMINATED NODE   READINESS GATES
nginx-74b5c74d54-569hj   1/1     Running   0          7d19h   10.64.2.4   ecs-matrix-k8s-cluster-worker02   <none>           <none>
```

### IPTABLES
#### Ingress 
##### On nodes where pods are NOT running
`INPUT` ==> `KUBE-EXTERNAL-SERVICES` ==> `DROP`

1. chain `INPUT` 
    ```bash
    $ sudo iptables -L INPUT -vn
    Chain INPUT (policy ACCEPT 503K packets, 79M bytes)
    pkts bytes target     prot opt in     out     source               destination
    988K   59M KUBE-PROXY-FIREWALL  all  --  *      *       0.0.0.0/0            0.0.0.0/0            ctstate NEW /* kubernetes load balancer firewall */
    101M   16G KUBE-NODEPORTS  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* kubernetes health check service ports */
    988K   59M KUBE-EXTERNAL-SERVICES  all  --  *      *       0.0.0.0/0            0.0.0.0/0            ctstate NEW /* kubernetes externally-visible service portals */
    101M   16G KUBE-FIREWALL  all  --  *      *       0.0.0.0/0            0.0.0.0/0

    $ grep '\-A INPUT' /tmp/iptables_local
    -A INPUT -m conntrack --ctstate NEW -m comment --comment "kubernetes load balancer firewall" -j KUBE-PROXY-FIREWALL
    -A INPUT -m comment --comment "kubernetes health check service ports" -j KUBE-NODEPORTS
    -A INPUT -m conntrack --ctstate NEW -m comment --comment "kubernetes externally-visible service portals" -j KUBE-EXTERNAL-SERVICES
    -A INPUT -j KUBE-FIREWALL
    ```

2. chain `KUBE-EXTERNAL-SERVICES` 
    ```bash
    $ sudo iptables -L KUBE-EXTERNAL-SERVICES -vn
    Chain KUBE-EXTERNAL-SERVICES (2 references)
    pkts bytes target     prot opt in     out     source               destination
        0     0 DROP       tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            /* default/nginx has no local endpoints */ ADDRTYPE match dst-type LOCAL tcp dpt:30783

    $ grep '\-A KUBE-EXTERNAL-SERVICES' /tmp/iptables_local
    -A KUBE-EXTERNAL-SERVICES -p tcp -m comment --comment "default/nginx has no local endpoints" -m addrtype --dst-type LOCAL -m tcp --dport 30783 -j DROP
    ```

##### On nodes where pods are running
`INPUT` ==> `KUBE-NODEPORTS` ==> `KUBE-EXT-2CMXP7HKUVJN7L6M` ==> `KUBE-SVL-2CMXP7HKUVJN7L6M` / `KUBE-SVC-2CMXP7HKUVJN7L6M` ==> `KUBE-SEP-YVT6EXXEKT4LDXBC`

1. chain `INPUT`
    ```bash
    $ sudo iptables -L INPUT -vn
    Chain INPUT (policy ACCEPT 3444 packets, 1570K bytes)
    pkts bytes target     prot opt in     out     source               destination
      268 21119 KUBE-PROXY-FIREWALL  all  --  *      *       0.0.0.0/0            0.0.0.0/0            ctstate NEW /* kubernetes load balancer firewall */
    951K  652M KUBE-NODEPORTS  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* kubernetes health check service ports */
      268 21119 KUBE-EXTERNAL-SERVICES  all  --  *      *       0.0.0.0/0            0.0.0.0/0            ctstate NEW /* kubernetes externally-visible service portals */
    963K  681M KUBE-FIREWALL  all  --  *      *       0.0.0.0/0            0.0.0.0/0

    $ grep '\-A INPUT' /tmp/iptables_local
    -A INPUT -m conntrack --ctstate NEW -m comment --comment "kubernetes load balancer firewall" -j KUBE-PROXY-FIREWALL
    -A INPUT -m comment --comment "kubernetes health check service ports" -j KUBE-NODEPORTS
    -A INPUT -m conntrack --ctstate NEW -m comment --comment "kubernetes externally-visible service portals" -j KUBE-EXTERNAL-SERVICES
    -A INPUT -j KUBE-FIREWALL
    ```

2. chain `KUBE-NODEPORTS` in table `nat`
    ```bash
    $ sudo iptables -t nat -L KUBE-NODEPORTS -vn
    Chain KUBE-NODEPORTS (1 references)
    pkts bytes target     prot opt in     out     source               destination
        0     0 KUBE-EXT-2CMXP7HKUVJN7L6M  tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            /* default/nginx */ tcp dpt:30783

    $ grep '\-A KUBE-NODEPORTS' /tmp/iptables_local
    -A KUBE-NODEPORTS -p tcp -m comment --comment "default/nginx" -m tcp --dport 30783 -j KUBE-EXT-2CMXP7HKUVJN7L6M
    ```

3. chain `KUBE-EXT-2CMXP7HKUVJN7L6M` in table `nat` 
    ```bash
    $ sudo iptables -t nat -L KUBE-EXT-2CMXP7HKUVJN7L6M -vn
    Chain KUBE-EXT-2CMXP7HKUVJN7L6M (1 references)
    pkts bytes target     prot opt in     out     source               destination
        0     0 KUBE-MARK-MASQ  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* masquerade LOCAL traffic for default/nginx external destinations */ ADDRTYPE match src-type LOCAL
        0     0 KUBE-SVC-2CMXP7HKUVJN7L6M  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* route LOCAL traffic for default/nginx external destinations */ ADDRTYPE match src-type LOCAL
        1    60 KUBE-SVL-2CMXP7HKUVJN7L6M  all  --  *      *       0.0.0.0/0            0.0.0.0/0

    $ grep '\-A KUBE-EXT-2CMXP7HKUVJN7L6M' /tmp/iptables_local
    -A KUBE-EXT-2CMXP7HKUVJN7L6M -m comment --comment "masquerade LOCAL traffic for default/nginx external destinations" -m addrtype --src-type LOCAL -j KUBE-MARK-MASQ
    -A KUBE-EXT-2CMXP7HKUVJN7L6M -m comment --comment "route LOCAL traffic for default/nginx external destinations" -m addrtype --src-type LOCAL -j KUBE-SVC-2CMXP7HKUVJN7L6M
    -A KUBE-EXT-2CMXP7HKUVJN7L6M -j KUBE-SVL-2CMXP7HKUVJN7L6M
    ```

4. chain `KUBE-SVL-2CMXP7HKUVJN7L6M` in table `nat` if src is from other hosts
    ```bash
    $ sudo iptables -t nat -L KUBE-SVL-2CMXP7HKUVJN7L6M -vn
    Chain KUBE-SVL-2CMXP7HKUVJN7L6M (1 references)
    pkts bytes target     prot opt in     out     source               destination
        1    60 KUBE-SEP-YVT6EXXEKT4LDXBC  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* default/nginx -> 10.64.2.4:80 */

    $ grep '\-A KUBE-SVL-2CMXP7HKUVJN7L6M' /tmp/iptables_local
    -A KUBE-SVL-2CMXP7HKUVJN7L6M -m comment --comment "default/nginx -> 10.64.2.4:80" -j KUBE-SEP-YVT6EXXEKT4LDXBC
    ```
    
    chain `KUBE-SVC-2CMXP7HKUVJN7L6M` in table `nat` if src is from local
    ```bash
    $ sudo iptables -t nat -L KUBE-SVC-2CMXP7HKUVJN7L6M -vn
    Chain KUBE-SVC-2CMXP7HKUVJN7L6M (2 references)
    pkts bytes target     prot opt in     out     source               destination
        0     0 KUBE-SEP-YVT6EXXEKT4LDXBC  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* default/nginx -> 10.64.2.4:80 */

    $ grep '\-A KUBE-SVC-2CMXP7HKUVJN7L6M' /tmp/iptables_local
    -A KUBE-SVC-2CMXP7HKUVJN7L6M -m comment --comment "default/nginx -> 10.64.2.4:80" -j KUBE-SEP-YVT6EXXEKT4LDXBC
    ```

5. chain `KUBE-SEP-YVT6EXXEKT4LDXBC` in table `nat` 
    ```bash
    $ grep '\-A KUBE-SEP-YVT6EXXEKT4LDXBC' /tmp/iptables_local
    -A KUBE-SEP-YVT6EXXEKT4LDXBC -s 10.64.2.4/32 -m comment --comment "default/nginx" -j KUBE-MARK-MASQ
    -A KUBE-SEP-YVT6EXXEKT4LDXBC -p tcp -m comment --comment "default/nginx" -m tcp -j DNAT --to-destination 10.64.2.4:80

    $ sudo iptables -t nat -L KUBE-SEP-YVT6EXXEKT4LDXBC -vn
    Chain KUBE-SEP-YVT6EXXEKT4LDXBC (2 references)
    pkts bytes target     prot opt in     out     source               destination
        0     0 KUBE-MARK-MASQ  all  --  *      *       10.64.2.4            0.0.0.0/0            /* default/nginx */
        1    60 DNAT       tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            /* default/nginx */ tcp to:10.64.2.4:80
    ```

#### Egress 


## Troubleshoot IPTABLES
via `LOG` module
```bash
sudo iptables -t nat -D KUBE-SVC-YVE4DVDYZJRPV46I -p tcp -j LOG --log-prefix "INPUT packets"
```

{% include links.html %}
