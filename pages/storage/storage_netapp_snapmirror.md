---
title: NetApp SnapMirror
tags: [storage]
keywords: NetApp, data protection, SnapMirror
last_updated: Sep 19, 2019
summary: "How to setup SnapMirror"
sidebar: mydoc_sidebar
permalink: storage_netapp_snapmirror.html
folder: storage
---

NetApp SnapMirror
======

### Env

- Source 
	- NetApp: NetAppCloudVolumeTest1 
	- SVM: svm_NetAppCloudVolumeTest1
	- Volume: SourceVolume
	- Intercluster LIF: 10.35.2.77/24

- Destination 
	- NetApp: NetAppCloudVolumeTest2
	- SVM: svm_NetAppCloudVolumeTest2
	- Volume:
	- Intercluster LIF: 10.35.2.130/24

### Intercluster LIF Setup

For Cloud Volumes ONTAP, Assign IP address to correponding Network Interfaces from AWS Console 

```
NetAppCloudVolumeTest1::> vserver show -type admin
                               Admin      Operational Root
Vserver     Type    Subtype    State      State       Volume     Aggregate
----------- ------- ---------- ---------- ----------- ---------- ----------
NetAppCloudVolumeTest1
            admin   -          -          -           -          -

NetAppCloudVolumeTest1::> network interface create -vserver NetAppCloudVolumeTest1 -lif NetAppCloudVolumeTest1_icl01 -address 10.35.2.77 -netmask-length 24 -role intercluster -home-port e0a

NetAppCloudVolumeTest1::> network interface show -role intercluster
            Logical    Status     Network            Current       Current Is
Vserver     Interface  Admin/Oper Address/Mask       Node          Port    Home
----------- ---------- ---------- ------------------ ------------- ------- ----
NetAppCloudVolumeTest1
            NetAppCloudVolumeTest1_icl01
                         up/up    10.35.2.77/24      NetAppCloudVolumeTest1-01
                                                                   e0a     true
```

```
NetAppCloudVolumeTest2::> vserver show -type admin
                               Admin      Operational Root
Vserver     Type    Subtype    State      State       Volume     Aggregate
----------- ------- ---------- ---------- ----------- ---------- ----------
NetAppCloudVolumeTest2
            admin   -          -          -           -          -

NetAppCloudVolumeTest2::> network interface create -vserver NetAppCloudVolumeTest2 -lif NetAppCloudVolumeTest12_icl01 -address 10.35.2.130 -netmask-length 24 -role intercluster -home-port e0a

NetAppCloudVolumeTest2::> network interface show  -role intercluster
            Logical    Status     Network            Current       Current Is
Vserver     Interface  Admin/Oper Address/Mask       Node          Port    Home
----------- ---------- ---------- ------------------ ------------- ------- ----
NetAppCloudVolumeTest2
            NetAppCloudVolumeTest12_icl01
                         up/up    10.35.2.130/24     NetAppCloudVolumeTest2-01
                                                                   e0a     true

```

Verify via `nmap`, TCP Ports: `10000`, `11104`, `11105` are for SnapMirror
```
[ec2-user@ip-10-35-2-8 ~]$ sudo nmap 10.35.2.77 -p 10000,11104,11105

Starting Nmap 6.40 ( http://nmap.org ) at 2019-09-02 03:18 UTC
Nmap scan report for ip-10-35-2-77.ec2.internal (10.35.2.77)
Host is up (0.000082s latency).
PORT      STATE SERVICE
10000/tcp open  snet-sensor-mgmt
11104/tcp open  unknown
11105/tcp open  unknown
MAC Address: 0A:9A:2E:86:9F:CE (Unknown)

Nmap done: 1 IP address (1 host up) scanned in 0.09 seconds

[ec2-user@ip-10-35-2-8 ~]$ sudo nmap 10.35.2.130 -p 10000,11104,11105

Starting Nmap 6.40 ( http://nmap.org ) at 2019-09-02 03:24 UTC
Nmap scan report for ip-10-35-2-130.ec2.internal (10.35.2.130)
Host is up (0.000082s latency).
PORT      STATE SERVICE
10000/tcp open  snet-sensor-mgmt
11104/tcp open  unknown
11105/tcp open  unknown
MAC Address: 0A:AF:84:52:80:68 (Unknown)

Nmap done: 1 IP address (1 host up) scanned in 0.10 seconds

```

### Cluster Peer Setup

```
NetAppCloudVolumeTest2::> cluster peer create -generate-passphrase -offer-expiration 2days -initial-allowed-vserver-peers svm_NetAppCloudVolumeTest2

Notice:
         Passphrase: +d2ZagtFWerU3FYuaLZ58o5h
         Expiration Time: 9/1/2019 09:34:15 +00:00
         Initial Allowed Vserver Peers: svm_NetAppCloudVolumeTest2
         Intercluster LIF IP: 10.35.2.130
         Peer Cluster Name: Clus_8o5h (temporary generated)

         Warning: make a note of the passphrase - it cannot be displayed again.


NetAppCloudVolumeTest1::> cluster peer create -peer-addrs 10.35.2.130

Notice: Use a generated passphrase or choose a passphrase of 8 or more characters. To ensure the
        authenticity of the peering relationship, use a phrase or sequence of characters that would
        be hard to guess.

Enter the passphrase:
Confirm the passphrase:

Notice: Clusters "NetAppCloudVolumeTest1" and "NetAppCloudVolumeTest2" are peered.

NetAppCloudVolumeTest1::> cluster peer show -instance

                       Peer Cluster Name: NetAppCloudVolumeTest2
           Remote Intercluster Addresses: 10.35.2.130
      Availability of the Remote Cluster: Available
                     Remote Cluster Name: NetAppCloudVolumeTest2
                     Active IP Addresses: 10.35.2.130
                   Cluster Serial Number: 1-80-000011
                    Remote Cluster Nodes: NetAppCloudVolumeTest2-01
                   Remote Cluster Health: true
                 Unreachable Local Nodes: -
          Address Family of Relationship: ipv4
    Authentication Status Administrative: use-authentication
       Authentication Status Operational: ok
                        Last Update Time: 8/30/2019 09:35:22
            IPspace for the Relationship: Default
Proposed Setting for Encryption of Inter-Cluster Communication: -
Encryption Protocol For Inter-Cluster Communication: tls-psk
```

### SVM Peer Setup

```
NetAppCloudVolumeTest2::> vserver peer show
There are no Vserver peer relationships.

NetAppCloudVolumeTest2::> vserver peer create -vserver svm_NetAppCloudVolumeTest2 -peer-vserver svm_NetAppCloudVolumeTest1 -peer-cluster NetAppCloudVolumeTest1 -applications snapmirror


NetAppCloudVolumeTest1::> vserver peer accept -vserver svm_NetAppCloudVolumeTest1 -peer-vserver svm_NetAppCloudVolumeTest2

NetAppCloudVolumeTest1::> vserver peer show
            Peer        Peer                           Peering        Remote
Vserver     Vserver     State        Peer Cluster      Applications   Vserver
----------- ----------- ------------ ----------------- -------------- ---------
svm_NetAppCloudVolumeTest1
            svm_NetAppCloudVolumeTest2
                        peered       NetAppCloudVolumeTest2
                                                       snapmirror     svm_NetAppCloudVolumeTest2
```

### Volume SnapMirror

```
NetAppCloudVolumeTest2::> volume create -vserver svm_NetAppCloudVolumeTest2 -volume MirrorDestVolume -type DP -size 100G -aggregate aggr1
[Job 88] Job succeeded: Successful

NetAppCloudVolumeTest2::> volume show -vserver svm_NetAppCloudVolumeTest2
Vserver   Volume       Aggregate    State      Type       Size  Available Used%
--------- ------------ ------------ ---------- ---- ---------- ---------- -----
svm_NetAppCloudVolumeTest2
          MirrorDestVolume
                       aggr1        online     DP        100GB   100.00GB    0%
svm_NetAppCloudVolumeTest2
          svm_NetAppCloudVolumeTest2_root
                       aggr1        online     RW          1GB    970.8MB    0%
2 entries were displayed.

NetAppCloudVolumeTest2::> snapmirror create -source-path svm_NetAppCloudVolumeTest1:SourceVolume -destination-path svm_NetAppCloudVolumeTest2:MirrorDestVolume -type XDP -policy MirrorAllSnapshots
Operation succeeded: snapmirror create for the relationship with destination "svm_NetAppCloudVolumeTest2:MirrorDestVolume".

NetAppCloudVolumeTest2::> snapmirror initialize -destination-path svm_NetAppCloudVolumeTest2:MirrorDestVolume
Operation is queued: snapmirror initialize of destination "svm_NetAppCloudVolumeTest2:MirrorDestVolume".

NetAppCloudVolumeTest2::> snapmirror show -fields lag-time,last-transfer-size,last-transfer-duration
source-path                             destination-path                            last-transfer-size last-transfer-duration lag-time
--------------------------------------- ------------------------------------------- ------------------ ---------------------- --------
svm_NetAppCloudVolumeTest1:SourceVolume svm_NetAppCloudVolumeTest2:MirrorDestVolume 3.96GB             0:0:49                 64:17:2

NetAppCloudVolumeTest2::> snapmirror show
                                                                       Progress
Source            Destination Mirror  Relationship   Total             Last
Path        Type  Path        State   Status         Progress  Healthy Updated
----------- ---- ------------ ------- -------------- --------- ------- --------
svm_NetAppCloudVolumeTest1:SourceVolume
            XDP  svm_NetAppCloudVolumeTest2:MirrorDestVolume
                              Snapmirrored
                                      Idle           -         true    -
```

### Manual Update SnapMirror

```
NetAppCloudVolumeTestHA::> snapmirror update -destination-path svm_NetAppCloudVolumeTestHA:NetAppCloudVolumeTestHA_data
Operation is queued: snapmirror update of destination "svm_NetAppCloudVolumeTestHA:NetAppCloudVolumeTestHA_data".

NetAppCloudVolumeTestHA::> snapmirror show -destination-path svm_NetAppCloudVolumeTestHA:NetAppCloudVolumeTestHA_data -fields lag,newest-snapshot-timestamp
source-path                             destination-path                                         newest-snapshot-timestamp lag-time
--------------------------------------- -------------------------------------------------------- ------------------------- --------
svm_NetAppCloudVolumeTest1:SourceVolume svm_NetAppCloudVolumeTestHA:NetAppCloudVolumeTestHA_data 09/19 07:35:27            0:2:6

NetAppCloudVolumeTestHA::> date
Node      Date                     Time zone
--------- ------------------------ -------------------------
NetAppCloudVolumeTestHA-01
          Thu Sep 19 07:37:41 2019 Etc/UTC
NetAppCloudVolumeTestHA-02
          Thu Sep 19 07:37:41 2019 Etc/UTC
2 entries were displayed.
```

### What will be stored in Snapshots 

#### Deleted Data while snapmirror was transferring will be included
```
NetAppCloudVolumeTest1::> snap show -volume SourceVolume
                                                                 ---Blocks---
Vserver  Volume   Snapshot                                  Size Total% Used%
-------- -------- ------------------------------------- -------- ------ -----
svm_NetAppCloudVolumeTest1
         SourceVolume
                  snapmirror.3e430262-cfd8-11e9-a813-53a7aecad837_2159983246.2019-09-19_074825
                                                          6.14MB     0%    0%
                  snapmirror.3e430262-cfd8-11e9-a813-53a7aecad837_2159983246.2019-09-19_075403
                                                          3.89MB     0%    0%
2 entries were displayed.
```

```
centos@ip-10-35-2-229.ec2.internal:/mnt/source · 07:48 AM Thu Sep 19 ·
!349 $ ll
total 13487808
-rw-r--r-- 1 root root 5268045824 Sep 10 17:49 1.img
-rw-r--r-- 1 root root 2147483648 Sep 10 17:50 2.img
-rw-r--r-- 1 root root 4194304000 Aug 31 06:36 3.img
-rw-r--r-- 1 root root 2147483648 Sep 19 07:42 4.img

centos@ip-10-35-2-229.ec2.internal:/mnt/source · 07:51 AM Thu Sep 19 ·
!352 $ sudo rm -f 2.img
```

```
NetAppCloudVolumeTest1::> snap show -volume SourceVolume
                                                                 ---Blocks---
Vserver  Volume   Snapshot                                  Size Total% Used%
-------- -------- ------------------------------------- -------- ------ -----
svm_NetAppCloudVolumeTest1
         SourceVolume
                  snapmirror.3e430262-cfd8-11e9-a813-53a7aecad837_2159983246.2019-09-19_074825
                                                          6.14MB     0%    0%
                  snapmirror.3e430262-cfd8-11e9-a813-53a7aecad837_2159983246.2019-09-19_075403
                                                          1.94GB     2%    9%
2 entries were displayed.
```

#### Newly added data will NOT be included in it
```
NetAppCloudVolumeTestHA::> snapmirror show
                                                                       Progress
Source            Destination Mirror  Relationship   Total             Last
Path        Type  Path        State   Status         Progress  Healthy Updated
----------- ---- ------------ ------- -------------- --------- ------- --------
svm_NetAppCloudVolumeTest1:SourceVolume
            XDP  svm_NetAppCloudVolumeTestHA:NetAppCloudVolumeTestHA_data
                              Snapmirrored
                                      Transferring   5.07GB    true    09/19 07:58:29
```

```
centos@ip-10-35-2-229.ec2.internal:/mnt/source · 07:54 AM Thu Sep 19 ·
!353 $ sudo dd if=/dev/urandom of=7.img bs=1M  count=4096
4096+0 records in
4096+0 records out
4294967296 bytes (4.3 GB) copied, 52.7619 s, 81.4 MB/s
```

```
NetAppCloudVolumeTest1::> snap show -volume SourceVolume
                                                                 ---Blocks---
Vserver  Volume   Snapshot                                  Size Total% Used%
-------- -------- ------------------------------------- -------- ------ -----
svm_NetAppCloudVolumeTest1
         SourceVolume
                  snapmirror.3e430262-cfd8-11e9-a813-53a7aecad837_2159983246.2019-09-19_074825
                                                          6.14MB     0%    0%
                  snapmirror.3e430262-cfd8-11e9-a813-53a7aecad837_2159983246.2019-09-19_075403
                                                          1.94GB     2%    8%
2 entries were displayed.
```

#### For modified data, original data will be included in it
```
centos@ip-10-35-2-229.ec2.internal:/mnt/source · 08:00 AM Thu Sep 19 ·
!354 $ ls -l
total 24014872
-rw-r--r-- 1 root root 5268045824 Sep 10 17:49 1.img
-rw-r--r-- 1 root root 4194304000 Aug 31 06:36 3.img
-rw-r--r-- 1 root root 2147483648 Sep 19 07:42 4.img
-rw-r--r-- 1 root root 4294967296 Sep 19 07:50 5.img
-rw-r--r-- 1 root root 4294967296 Sep 19 07:51 6.img
-rw-r--r-- 1 root root 4294967296 Sep 19 07:58 7.img

centos@ip-10-35-2-229.ec2.internal:/mnt/source · 08:00 AM Thu Sep 19 ·
!355 $ sudo dd if=/dev/urandom of=3.img bs=1M  count=1024
1024+0 records in
1024+0 records out
1073741824 bytes (1.1 GB) copied, 15.4966 s, 69.3 MB/s

centos@ip-10-35-2-229.ec2.internal:/mnt/source · 08:01 AM Thu Sep 19 ·
!356 $ ls -l
total 20955452
-rw-r--r-- 1 root root 5268045824 Sep 10 17:49 1.img
-rw-r--r-- 1 root root 1073741824 Sep 19 08:01 3.img
-rw-r--r-- 1 root root 2147483648 Sep 19 07:42 4.img
-rw-r--r-- 1 root root 4294967296 Sep 19 07:50 5.img
-rw-r--r-- 1 root root 4294967296 Sep 19 07:51 6.img
-rw-r--r-- 1 root root 4294967296 Sep 19 07:58 7.img
```

```
NetAppCloudVolumeTest1::> snap show -volume SourceVolume
                                                                 ---Blocks---
Vserver  Volume   Snapshot                                  Size Total% Used%
-------- -------- ------------------------------------- -------- ------ -----
svm_NetAppCloudVolumeTest1
         SourceVolume
                  snapmirror.3e430262-cfd8-11e9-a813-53a7aecad837_2159983246.2019-09-19_075403
                                                          5.94GB     6%   22%
```

{% include links.html %}
