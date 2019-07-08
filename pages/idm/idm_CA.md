---
title: CA(Certificate Authority)
tags: [idm]
keywords: certs, tls, ssl
last_updated: July 7th, 2019
summary: "Self-signed CA Setup"
sidebar: mydoc_sidebar
permalink: idm_ca.html
folder: idm
---

CA(Certificate Authority)
======

### Certs Path Config  
Open `/etc/pki/tls/openssl.cnf`, find the section labeled `[ CA_default ]`, and edit as the following:

```bash
dir = /etc/pki/CA
certificate = $dir/my-ca.crt
crl = $dir/my-ca.crl
private_key = $dir/private/my-ca.key
```

### Certs Info

The `[ req_distinguished_name ]` section lists several default options for authorized certs
```bash
countryName_default = US
stateOrProvinceName_default = New York
localityName_default = New York
0.organizationName_default = Example
```

### Cert Matching Policy

Policy choosen was in section `[ CA_default ]`
```bash
policy          = policy_match
```

### Cert Policy in detail

```bash
# For the CA policy
[ policy_match ]
countryName             = match
stateOrProvinceName     = match
organizationName        = match
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional
```

### Generate CA pricate key / public cert

#### Create all directories needed
```
# mkdir /etc/pki/CA/{certs,crl,newcerts}
```

#### Create an empty certificate index:
```
# touch /etc/pki/CA/index.txt
```

#### In addition, create a file to indicate the next certificate serial number to be issued:
# echo 01 > /etc/pki/CA/serial

#### Generate CA private key
```
# (umask 077; openssl genrsa -out /etc/pki/CA/private/my-ca.key -des3 2048)
Generating RSA private key, 2048 bit long modulus
...................................+++
......................+++
e is 65537 (0x10001)
Enter pass phrase for /etc/pki/CA/private/my-ca.key:
Verifying - Enter pass phrase for /etc/pki/CA/private/my-ca.key:
```

#### Generate CA public key

```bash
# openssl req -new -x509 -key /etc/pki/CA/private/my-ca.key -days 365 > /etc/pki/CA/my-ca.crt
Enter pass phrase for /etc/pki/CA/private/my-ca.key:
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [US]:
State or Province Name (full name) [New York]:
Locality Name (eg, city) [New York]:
Organization Name (eg, company) [Example]:
Organizational Unit Name (eg, section) []:OPS
Common Name (eg, your name or your server's hostname) []:ca.example.net
Email Address []:root@ca.example.net
```

### Check Cert Request Content

```bash
# openssl req -in /tmp/request.req -noout -text
Certificate Request:
    Data:
        Version: 0 (0x0)
        Subject: C=US, ST=New York, O=Example, CN=win12r2.example.com
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (1024 bit)
                Modulus:
                    00:d8:aa:14:e0:07:15:b2:d5:eb:63:a9:2f:25:20:
                    f2:99:bc:61:69:a8:a9:f0:75:28:97:ee:57:b4:a3:
                    b1:35:cb:b3:20:f6:e6:11:62:d5:4b:d5:c8:29:7f:
                    e6:aa:0e:13:0a:7c:66:21:9d:57:5d:5e:e2:7f:66:
                    31:8b:35:dc:cd:bb:c6:b1:bc:07:fe:6f:49:cf:e6:
                    cb:9b:83:42:dc:ea:56:b6:57:c1:10:8e:5a:92:6c:
                    20:bd:48:f9:da:4e:a7:eb:5e:09:16:77:89:93:e0:
                    93:2a:84:0e:da:d9:41:82:19:6b:89:e6:14:9a:e9:
                    f5:61:6f:7c:f0:39:b7:d9:8d
                Exponent: 65537 (0x10001)
        Attributes:
            1.3.6.1.4.1.311.13.2.3   :6.2.9200.2
            1.3.6.1.4.1.311.21.20    :unable to print attribute
            1.3.6.1.4.1.311.13.2.2   :unable to print attribute
        Requested Extensions:
            X509v3 Key Usage: critical
                Digital Signature, Key Encipherment
            X509v3 Extended Key Usage:
                TLS Web Server Authentication
            X509v3 Subject Key Identifier:
                41:8D:BC:E4:B5:62:7D:DA:23:07:5A:C7:F9:E0:63:50:25:3B:E2:62
    Signature Algorithm: sha1WithRSAEncryption
         4b:59:db:92:42:aa:57:41:51:51:55:7a:5d:55:7c:a5:d6:5b:
         8b:07:bf:98:1a:c0:32:94:45:15:6d:9a:f7:de:89:52:41:d3:
         db:40:00:a7:dd:28:8f:a9:d4:45:99:23:06:89:e5:d9:01:4a:
         b8:a3:6f:44:52:16:79:7f:cf:3b:38:bc:41:be:ef:80:ee:10:
         ff:e7:2a:68:57:09:71:b0:a7:e0:ec:a0:66:ad:d1:f6:fa:18:
         0b:bb:a2:e5:9b:99:00:04:69:7b:a3:22:2c:09:cb:0e:7a:9e:
         fb:b3:5c:26:33:4a:19:fe:c9:6e:52:82:67:16:35:fa:67:ca:
         00:0f
```

{% include links.html %}
