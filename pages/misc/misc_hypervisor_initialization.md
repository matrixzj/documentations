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

`remove default NAT bridge`
```bash
# virsh net-list
 Name                 State      Autostart     Persistent
----------------------------------------------------------
 default              active     yes           yes

# virsh net-destroy default
Network default destroyed

# virsh net-undefine default
Network default has been undefined
```

`config a new bridge`
```
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

`Enble libvirt TCP listen`
```bash
# diff -u /etc/sysconfig/libvirtd{,.orig}
--- /etc/sysconfig/libvirtd     2019-06-29 04:51:15.601536416 +0000
+++ /etc/sysconfig/libvirtd.orig        2019-06-29 04:50:34.197483618 +0000
@@ -6,7 +6,7 @@

 # Listen for TCP/IP connections
 # NB. must setup TLS/SSL keys prior to using this
-LIBVIRTD_ARGS="--listen"
+#LIBVIRTD_ARGS="--listen"

# diff -u /etc/libvirt/libvirtd.conf{,.orig}
--- /etc/libvirt/libvirtd.conf  2019-06-29 04:52:59.835812187 +0000
+++ /etc/libvirt/libvirtd.conf.orig     2019-06-29 04:52:37.898775202 +0000
@@ -491,5 +491,3 @@
 # potential infinite waits blocking libvirt.
 #
 #ovs_timeout = 5
-listen_tls = 0
-listen_tcp = 1

`MD5 Auth Enable`
```bash
# diff -u /etc/sasl2/libvirt.conf{,.orig}
--- /etc/sasl2/libvirt.conf     2019-06-29 05:27:42.096793960 +0000
+++ /etc/sasl2/libvirt.conf.orig        2019-06-29 04:55:13.358973492 +0000
@@ -18,7 +18,7 @@
 # To use GSSAPI requires that a libvirtd service principal is
 # added to the Kerberos server for each host running libvirtd.
 # This principal needs to be exported to the keytab file listed below
-mech_list: digest-md5
+mech_list: gssapi

 # If using a TLS socket or UNIX socket only, it is possible to
 # enable plugins which don't provide session encryption. The
@@ -37,9 +37,9 @@
 # instead need KRB5_KTNAME env var.
 # For modern Linux, and other OS, this should be sufficient
 #
-# keytab: /etc/libvirt/krb5.tab
+keytab: /etc/libvirt/krb5.tab

 # If using scram-sha-1 for username/passwds, then this is the file
 # containing the passwds. Use 'saslpasswd2 -a libvirt [username]'
 # to add entries, and 'sasldblistusers2 -f [sasldb_path]' to browse it
-sasldb_path: /etc/libvirt/passwd.db
+#sasldb_path: /etc/libvirt/passwd.db
```

`Add User for libvirt TCP Auth`
```bash
# yum install cyrus-sasl-md5

# saslpasswd2 -a libvirt root
Password:
Again (for verification):

# sasldblistusers2 -f /etc/libvirt/passwd.db
root@pekdev015.dev.fwmrm.net: userPassword

# systemctl restart libvirtd
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
