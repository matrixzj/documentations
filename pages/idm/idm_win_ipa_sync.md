---
title: IPA / Win AD Sync
tags: [idm]
keywords: ipa, ad, passwod, sync
last_updated: June 25, 2019
summary: "IPA to Windows AD Domain Password / User Sync"
sidebar: mydoc_sidebar
permalink: idm_ipa_win_sync.html
folder: idm
---

## IPA / Win AD Sync

### Preparation: Bind DNS Setup

`/etc/named.conf` config file

```bash
# diff -Nru /etc/named.conf /etc/named.conf.orig
--- /etc/named.conf     2019-06-25 05:41:58.938614759 +0000
+++ /etc/named.conf.orig        2019-01-29 17:23:30.000000000 +0000
@@ -10,15 +10,15 @@
 // configuration located in /usr/share/doc/bind-{version}/Bv9ARM.html

 options {
-       listen-on port 53 { any; };
-       listen-on-v6 { none; };
+       listen-on port 53 { 127.0.0.1; };
+       listen-on-v6 port 53 { ::1; };
        directory       "/var/named";
        dump-file       "/var/named/data/cache_dump.db";
        statistics-file "/var/named/data/named_stats.txt";
        memstatistics-file "/var/named/data/named_mem_stats.txt";
        recursing-file  "/var/named/data/named.recursing";
        secroots-file   "/var/named/data/named.secroots";
-       allow-query     { any; };
+       allow-query     { localhost; };

        /*
         - If you are building an AUTHORITATIVE DNS server, do NOT enable recursion.
@@ -32,8 +32,8 @@
        */
        recursion yes;

-       dnssec-enable no;
-       dnssec-validation no;
+       dnssec-enable yes;
+       dnssec-validation yes;

        /* Path to ISC DLV key */
        bindkeys-file "/etc/named.iscdlv.key";
@@ -42,10 +42,6 @@

        pid-file "/run/named/named.pid";
        session-keyfile "/run/named/session.key";
-
-       forwarders {
-               192.168.14.21;
-       };
 };

 logging {
@@ -60,14 +56,6 @@
        file "named.ca";
 };

-zone "example.net"                     in { type master; file "db.example.net"; };
-zone "0.168.192.in-addr.arpa"          in { type master; file "db.192.168.0"; };
-zone "examplemedia.tv"                 in { type forward;
-                                               forward only;
-                                               forwarders { 192.168.0.47; };
-                                               check-names ignore;
-                                       };
-
 include "/etc/named.rfc1912.zones";
 include "/etc/named.root.key";
```

zonefile `db.example.net`
```bash
# cat /var/named/db.example.net
$TTL    1h
@                       IN      SOA     ns1.example.net. hostmaster.example.net. (
                                        2019060803      ; serial
                                        3h              ; refresh
                                        1h              ; retry
                                        2w              ; expire
                                        1h              ; negative-cache
                                        )

@               1d      IN      NS      dns.example.net.

dns             IN      A       192.168.0.48
ipa             IN      A       192.168.0.49
client1         IN      A       192.168.0.75

; ldap servers
_ldap._tcp              IN SRV 0 100 389        ipa
;kerberos realm
_kerberos               IN TXT EXAMPLE.NET
; kerberos servers
_kerberos._tcp          IN SRV 0 100 88         ipa
_kerberos._udp          IN SRV 0 100 88         ipa
_kerberos-master._tcp   IN SRV 0 100 88         ipa
_kerberos-master._udp   IN SRV 0 100 88         ipa
_kpasswd._tcp           IN SRV 0 100 464        ipa
_kpasswd._udp           IN SRV 0 100 464        ipa
_ldap._tcp.dc._msdcs    IN SRV 0 100 389        ipa
_kerberos._udp.dc._msdcs        IN SRV 0 100 88         ipa
_ldap._tcp.Default-First-Site-Name._sites.dc._msdcs     IN SRV 0 100 389        ipa
_kerberos._tcp.Default-First-Site-Name._sites.dc._msdcs IN SRV 0 100 88         ipa
_kerberos._tcp.dc._msdcs                                IN SRV 0 100 88         ipa
_kerberos._udp.Default-First-Site-Name._sites.dc._msdcs IN SRV 0 100 88         ipa
```

zonefile `db.192.168.0.`
```bash
# cat /var/named/db.192.168.0
$TTL    1h
@                       IN      SOA     ns1.example.net. hostmaster.example.net. (
                                        2019060802      ; serial
                                        3h              ; refresh
                                        1h              ; retry
                                        2w              ; expire
                                        1h              ; negative-cache
                                        )

@               1d      IN      NS      dns.example.net.

48              IN      PTR     dns.example.net.
49              IN      PTR     ipa.example.net.
75              IN      PTR     client1.example.net.
```

### Preparation: Windows AD Setup

1. Network Setup
    - IP Address Assignment 
    - Disable Firewall
    - Hostname Change

2. AD Controller / CA Setup
   - Add roles to Window  

    ![sync01](images/idm/ipa_win_sync_01.png)

    `Role-based or feature-based installation`  
    ![sync02](images/idm/ipa_win_sync_02.png)

    `Select a server from the server pool`  
    ![sync03](images/idm/ipa_win_sync_03.png)

    - Windows Domain Controller 

    DC installation firstly  
    ![sync05](images/idm/ipa_win_sync_05.png)

    `Add a new forest` named as `examplemedia.net`  
    ![dc1](images/idm/ipa_win_sync_dc_01.png)

    Password Set  
    ![dc2](images/idm/ipa_win_sync_dc_02.png)

    Leave `DNS` as default  
    ![dc3](images/idm/ipa_win_sync_dc_03.png)

    Leave `NetBIOS` as default `EXAMPLEMEDIA`  
    ![dc4](images/idm/ipa_win_sync_dc_04.png)

    Leave `Paths` as default  
    ![dc5](images/idm/ipa_win_sync_dc_05.png)

    `Review Options` and `Next`  
    ![dc6](images/idm/ipa_win_sync_dc_06.png)

    `Install`  
    ![dc7](images/idm/ipa_win_sync_dc_07.png)

a01
![dc01](images/idm/ipa_win_sync_ca_001.png)
a02
![dc02](images/idm/ipa_win_sync_ca_002.png)
a03
![dc03](images/idm/ipa_win_sync_ca_003.png)
a04
![dc04](images/idm/ipa_win_sync_ca_004.png)
a05
![dc05](images/idm/ipa_win_sync_ca_005.png)
a06
![dc06](images/idm/ipa_win_sync_ca_006.png)
a07
![dc07](images/idm/ipa_win_sync_ca_007.png)
a08
![dc08](images/idm/ipa_win_sync_ca_008.png)
a09
![dc09](images/idm/ipa_win_sync_ca_009.png)
a10
![dc10](images/idm/ipa_win_sync_ca_010.png)
a11
![dc11](images/idm/ipa_win_sync_ca_011.png)
a12
![dc12](images/idm/ipa_win_sync_ca_012.png)
a13
![dc13](images/idm/ipa_win_sync_ca_013.png)

    test1
    ![sync06](images/idm/ipa_win_sync_06.png)

    test2
    ![sync07](images/idm/ipa_win_sync_07.png)

    test3
    ![sync08](images/idm/ipa_win_sync_08.png)

    test4
    ![sync09](images/idm/ipa_win_sync_09.png)

    test5
    ![sync10](images/idm/ipa_win_sync_10.png)

    test6
    ![sync11](images/idm/ipa_win_sync_11.png)

    test7
    ![sync04](images/idm/ipa_win_sync_04.png)

{% include links.html %}
