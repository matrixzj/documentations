---
title: Hypervisor Initialization
tags: [misc]
keywords: virt-install
last_updated: June 29, 2019
summary: "Build a raw host to KVM based Hypervisor"
sidebar: mydoc_sidebar
permalink: misc_hypervisor_initialization.html
folder: Misc
---

## Hypervisor Initialization
=====

### RPM Installation

```bash
# yum install -y virt-install qemu libvirt
# systemctl enable --now libvirtd
```

### Bridge Config

```bash
# virsh net-list
 Name                 State      Autostart     Persistent
----------------------------------------------------------
 default              active     yes           yes

# virsh net-destroy default
Network default destroyed

# virsh net-undefine default
Network default has been undefined

# cat /etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE=eth0
BOOTPROTO=none
ONBOOT=yes
BRIDGE=br0
TYPE=Ethernet

# cat /etc/sysconfig/network-scripts/ifcfg-br0
DEVICE=br0
BOOTPROTO=static
IPADDR=192.168.0.15
NETMASK=255.255.255.0
GATEWAY=192.168.0.1
ONBOOT=yes
TYPE=Bridge

# systemctl restart network

# brctl show
bridge name     bridge id               STP enabled     interfaces
br0             8000.ecb1d77fa580       no              eth0
```

### TCP Connection and Auth 

```bash
# diff -u /etc/sysconfig/libvirtd{,.orig}
--- /etc/sysconfig/libvirtd     2019-06-29 04:51:15.601536416 +0000
+++ /etc/sysconfig/libvirtd.orig        2019-06-29 04:50:34.197483618 +0000
@@ -6,7 +6,7 @@

 # Listen for TCP/IP connections
 # NB. must setup TLS/SSL keys prior to using this
-LIBVIRTD_ARGS="--listen"
+#LIBVIRTD_ARGS="--listen"

# diff /etc/libvirt/libvirtd.conf{,.orig}
494,495d493
< listen_tls = 0
< listen_tcp = 1

 # Override Kerberos service keytab for SASL/GSSAPI
 #KRB5_KTNAME=/etc/libvirt/krb5.tab

# yum install cyrus-sasl-md5

# systemctl restart libvirtd

# saslpasswd2 -a libvirt fred
```

`Verify Connection`
```bash
# virsh -c qemu+tcp://localhost/system nodeinfo
Please enter your authentication name: root
Please enter your password:
CPU model:           x86_64
CPU(s):              48
CPU frequency:       2300 MHz
CPU socket(s):       1
Core(s) per socket:  12
Thread(s) per core:  2
NUMA cell(s):        2
Memory size:         134089036 KiB
```

[Modify images](https://docs.openstack.org/image-guide/modify-images.html)

{% include links.html %}
