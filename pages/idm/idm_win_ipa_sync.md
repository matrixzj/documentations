---
title: IPA / Win AD Sync
tags: [idm]
keywords: ipa, ad, passwod, sync
last_updated: June 27, 2019
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

#### Network Setup
- IP Address Assignment 
- Disable Firewall
- Hostname Change

#### Add `Domin Controller` 

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

#### Add `Certificate Service` 

Domain Controller will automatically register itself to CA and retrieve cert.

![sync04](images/idm/ipa_win_sync_04.png)

Leave `Credentials` as default  
![dc02](images/idm/ipa_win_sync_ca_02.png)

Leave `Role Services` as `Certification Authority`  
![dc03](images/idm/ipa_win_sync_ca_03.png)

CA Type `Enterprise CA`  
![dc04](images/idm/ipa_win_sync_ca_04.png)

CA Type `Root CA`   
![dc05](images/idm/ipa_win_sync_ca_05.png)

`Create a new private key`  
![dc06](images/idm/ipa_win_sync_ca_06.png)

Private key cryptographic options: algorithm as `MD5`, key length `2048`  
![dc07](images/idm/ipa_win_sync_ca_07.png)

Leave `CA Name` as default  
![dc13](images/idm/ipa_win_sync_ca_13.png)

Validity Period as `5 years`  
![dc09](images/idm/ipa_win_sync_ca_09.png)

Leave `Certificate Database locations` as default  
![dc10](images/idm/ipa_win_sync_ca_10.png)

`Configure`  
![dc11](images/idm/ipa_win_sync_ca_11.png)

Verify LDAPS via `ldp` in Windows AD

#### Alternative: Get Cert from 3rd Party CA

##### Create the .inf file, which be used to create the certificate request
```bash
# cat request.inf
;----------------- request.inf -----------------

[Version]

Signature="$Windows NT$

[NewRequest]

Subject = "CN=win12r2.example.com, O=Example, S=New York, C=US" ; replace with the FQDN of the DC
KeySpec = 1
KeyLength = 1024
; Can be 1024, 2048, 4096, 8192, or 16384.
; Larger key sizes are more secure, but have
; a greater impact on performance.
Exportable = TRUE
MachineKeySet = TRUE
SMIME = False
PrivateKeyArchive = FALSE
UserProtected = FALSE
UseExistingKeySet = FALSE
ProviderName = "Microsoft RSA SChannel Cryptographic Provider"
ProviderType = 12
RequestType = PKCS10
KeyUsage = 0xa0

[EnhancedKeyUsageExtension]

OID=1.3.6.1.5.5.7.3.1 ; this is for Server Authentication

;-----------------------------------------------
```

Note: Some third-party certification authorities may require additional information in the Subject parameter. Such information includes an e-mail address (E), organizational unit (OU), organization (O), locality or city (L), state or province (S), and country or region (C). You can append this information to the Subject name (CN) in the Request.inf file. 

##### Generate Request File
```
certreq -new request.inf request.req
```
[Generate Request File](images/idm/ipa_win_sync_ca_14.png)

##### Sign this Request on CA host 
```bash
# openssl ca -in /tmp/request.csr -out /tmp/windows.crt
Using configuration from /etc/pki/tls/openssl.cnf
Enter pass phrase for /etc/pki/CA/private/my-ca.key:
Check that the request matches the signature
Signature ok
Certificate Details:
        Serial Number: 3 (0x3)
        Validity
            Not Before: Jul  8 08:38:13 2019 GMT
            Not After : Jul  7 08:38:13 2020 GMT
        Subject:
            countryName               = US
            stateOrProvinceName       = New York
            organizationName          = Example
            commonName                = win12r2.example.com
        X509v3 extensions:
            X509v3 Basic Constraints:
                CA:FALSE
            Netscape Comment:
                OpenSSL Generated Certificate
            X509v3 Subject Key Identifier:
                41:26:57:F9:91:36:32:53:30:1B:AC:06:63:FA:3B:38:51:64:E6:BB
            X509v3 Authority Key Identifier:
                keyid:CC:12:A6:8A:EA:74:08:85:B3:DC:51:91:E8:F7:31:9D:8D:5B:3A:B4

Certificate is to be certified until Jul  7 08:38:13 2020 GMT (365 days)
Sign the certificate? [y/n]:y


1 out of 1 certificate requests certified, commit? [y/n]y
Write out database with 1 new entries
Data Base Updated
```

##### Import CA Certs to Windows AD

Start->Run...-> Type "mmc". This will open the "Add/Remove Snap-in" dialog.
![ca15](images/idm/ipa_win_sync_ca_15.png)

In the "Add Snap-in" dialog, select "Certificates" and press "Next".
![ca16](images/idm/ipa_win_sync_ca_16.png)

Select "Computer account" and press "Next".
![ca17](images/idm/ipa_win_sync_ca_17.png)

Select "Local computer" and press "Finish"
![ca18](images/idm/ipa_win_sync_ca_18.png)

Expand the "Certificates" node under "Third-Party Root Certification Authorities". Right-click on the "Certificates" node, select "All Tasks" -> "Import...", and import the Certificate Authority ("my-ca.crt") copied from CA hosts.
![ca19](images/idm/ipa_win_sync_ca_19.png)
![ca20](images/idm/ipa_win_sync_ca_20.png)
![ca21](images/idm/ipa_win_sync_ca_21.png)
![ca22](images/idm/ipa_win_sync_ca_22.png)

##### Accept Signed Cert in Windows AD Server
```bash
certreq -accept windows.crt
```
![ca23](images/idm/ipa_win_sync_ca_23.png)

##### Restart Windows AD Server to take it effect and verify with `ldp` tool

#### Verify AD / CS from IPA side

ldap toolsets config file `/etc/openldap/ldap.conf` 

```bash
# diff -u /etc/openldap/ldap.conf /etc/openldap/ldap.conf.orig
--- /etc/openldap/ldap.conf     2019-06-27 03:09:48.477021995 +0000
+++ /etc/openldap/ldap.conf.orig        2019-06-27 03:10:13.174061765 +0000
@@ -1,14 +1,3 @@
-# File modified by ipa-client-install
-
-# We do not want to break your existing configuration, hence:
-#   URI, BASE and TLS_CACERT have been added if they were not set.
-#   In case any of them were set, a comment with trailing note
-#   "# modified by IPA" note has been inserted.
-# To use IPA server with openLDAP tools, please comment out your
-# existing configuration for these options and uncomment the
-# corresponding lines generated by IPA.
-
-
 #
 # LDAP Defaults
 #
@@ -23,12 +12,7 @@
 #TIMELIMIT     15
 #DEREF         never

-# TLS_CACERTDIR /etc/openldap/cacerts
+TLS_CACERTDIR  /etc/openldap/certs

 # Turning this off breaks GSSAPI used with krb5 when rdns = false
 SASL_NOCANON   on
-URI ldaps://ipa.example.net
-BASE dc=example,dc=net
-TLS_CACERT /etc/ipa/ca.crt
-
-TLS_CACERT /etc/openldap/cacerts/windows-ca.cer
```

Verify via `ldapsearch`

```bash
# ldapsearch -H ldaps://win12r2.examplemedia.net:636 -b 'OU=BJ,OU=CN,OU=User Accounts,DC=examplemedia,DC=net' -D 'CN=Administrator,CN=Users,DC=examplemedia,DC=net' -W objectClass=organizationalPerson
Enter LDAP Password:
dn: CN=Matrix Zou,OU=BJ,OU=CN,OU=User Accounts,DC=examplemedia,DC=net
objectClass: top
objectClass: person
objectClass: organizationalPerson
objectClass: user
cn: Matrix Zou
sn: Zou
givenName: Matrix
distinguishedName: CN=Matrix Zou,OU=BJ,OU=CN,OU=User Accounts,DC=examplemedia,
 DC=net
instanceType: 4
whenCreated: 20190627100916.0Z
whenChanged: 20190627100916.0Z
displayName: Matrix Zou
uSNCreated: 16463
uSNChanged: 16468
name: Matrix Zou
objectGUID:: RPbzwrWBf06iRlHbAeUkaw==
userAccountControl: 66048
badPwdCount: 0
codePage: 0
countryCode: 0
badPasswordTime: 0
lastLogoff: 0
lastLogon: 0
pwdLastSet: 132061037566163225
primaryGroupID: 513
objectSid:: AQUAAAAAAAUVAAAA9T0sySwvTsMmGcWgUAQAAA==
accountExpires: 9223372036854775807
logonCount: 0
sAMAccountName: jzou
sAMAccountType: 805306368
userPrincipalName: jzou@examplemedia.net
objectCategory: CN=Person,CN=Schema,CN=Configuration,DC=examplemedia,DC=net
dSCorePropagationData: 16010101000000.0Z
```

#### Reboot to take it in effect

### IPA Installation

```bash
# ipa-server-install -r EXAMPLE.NET -n example.net -p example -a example -N --hostname=ipa.example.net -U
```

### IPA <---> Windown Sync Agreement Setup

```bash
# ipa-replica-manage connect --winsync --binddn 'cn=administrator,cn=users,dc=examplemedia,dc=net' --bindpw 'Ex@ample' --passsync secretpwd --cacert /etc/openldap/cacerts/windows-ca.cer win12r2.examplemedia.net --win-subtree 'OU=User Accounts,DC=examplemedia,DC=net' -v
Added CA certificate /etc/openldap/cacerts/windows-ca.cer to certificate database for ipa.example.net
ipa: INFO: AD Suffix is: DC=examplemedia,DC=net
The user for the Windows PassSync service is uid=passsync,cn=sysaccounts,cn=etc,dc=example,dc=net
Adding Windows PassSync system account
ipa: INFO: Added new sync agreement, waiting for it to become ready . . .
ipa: INFO: Replication Update in progress: FALSE: status: Error (0) Replica acquired successfully: Incremental update started: start: 0: end: 0
ipa: INFO: Agreement is ready, starting replication . . .
Starting replication, please wait until this has completed.

Update succeeded

Connected 'ipa.example.net' to 'win12r2.examplemedia.net'

# ipa-replica-manage list
ipa.example.net: master
win12r2.examplemedia.net: winsync
```

### Password Sync Windows Sync Plugin Setup

Install `RedHat-PassSync-1.1.7-x86_64.msi` and configure it as below
![passwd_01](images/idm/ipa_win_sync_passwd_01.png)

Import IPA CA cert into Windows AD Server   
`C:\Program Files\Red Hat Directory Password Synchronization\certutil.exe -d . -A -t CT,, -n "IPACA" -a -i ipa-ca.crt`  
![passwd_01](images/idm/ipa_win_sync_passwd_02.png)  
NOTE: `List Installed Cert`  
`C:\Program Files\Red Hat Directory Password Synchronization\certutil.exe -d . -L`

{% include links.html %}
