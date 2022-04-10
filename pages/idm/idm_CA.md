---
title: CA(Certificate Authority)
tags: [idm]
keywords: certs, tls, ssl
last_updated: Apr 10, 2022
summary: "Self-signed CA Setup"
sidebar: mydoc_sidebar
permalink: idm_ca.html
folder: idm
---

CA(Certificate Authority)
======

## CA config file
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

## Generate CA pricate key / public cert

### Create all directories needed
```
# mkdir /etc/pki/CA/{certs,crl,newcerts}
```

### Create an empty certificate index:
```
# touch /etc/pki/CA/index.txt
```

### In addition, create a file to indicate the next certificate serial number to be issued:
```
# echo 01 > /etc/pki/CA/serial
```

### Generate CA private key
```
# (umask 077; openssl genrsa -out /etc/pki/CA/private/my-ca.key -des3 2048)
Generating RSA private key, 2048 bit long modulus
...................................+++
......................+++
e is 65537 (0x10001)
Enter pass phrase for /etc/pki/CA/private/my-ca.key:
Verifying - Enter pass phrase for /etc/pki/CA/private/my-ca.key:
```

### Generate CA public key

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

### Generate Cert Sign request
```bash
$ openssl req -new -newkey rsa:2048 -nodes -keyout master01.example.net.key -out master01.example.net.csr
Generating a 2048 bit RSA private key
..................+++
.......................................+++
writing new private key to 'master01.example.net.key'
-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [XX]:CN
State or Province Name (full name) []:Beijing
Locality Name (eg, city) [Default City]:Beijing
Organization Name (eg, company) [Default Company Ltd]:MA
Organizational Unit Name (eg, section) []:Matrix
Common Name (eg, your name or your server's hostname) []:master01.example.net
Email Address []:root@master01.net

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:

$ ls -l  master01.example.net.*
-rw-rw-r-- 1 jun_zou jun_zou 1062 Apr 10 08:01 master01.example.net.csr
-rw-rw-r-- 1 jun_zou jun_zou 1704 Apr 10 08:01 master01.example.net.key
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

### Sign a cert based on request
```
# openssl ca -in /tmp/request.req -out /tmp/windows.crt
Using configuration from /etc/pki/tls/openssl.cnf
Enter pass phrase for /etc/pki/CA/private/my-ca.key:
Check that the request matches the signature
Signature ok
Certificate Details:
        Serial Number: 2 (0x2)
        Validity
            Not Before: Jul  8 06:13:38 2019 GMT
            Not After : Jul  7 06:13:38 2020 GMT
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
                41:8D:BC:E4:B5:62:7D:DA:23:07:5A:C7:F9:E0:63:50:25:3B:E2:62
            X509v3 Authority Key Identifier:
                keyid:CC:12:A6:8A:EA:74:08:85:B3:DC:51:91:E8:F7:31:9D:8D:5B:3A:B4

Certificate is to be certified until Jul  7 06:13:38 2020 GMT (365 days)
Sign the certificate? [y/n]:y


1 out of 1 certificate requests certified, commit? [y/n]y
Write out database with 1 new entries
Data Base Updated
```

### Revoke a cert
```bash
# openssl ca -revoke /etc/pki/CA/newcerts/02.pem
Using configuration from /etc/pki/tls/openssl.cnf
Enter pass phrase for /etc/pki/CA/private/my-ca.key:
Revoking Certificate 02.
Data Base Updated
```

```bash
# openssl crl -in /etc/pki/CA/my-ca.crl -noout -text
Certificate Revocation List (CRL):
        Version 2 (0x1)
    Signature Algorithm: sha256WithRSAEncryption
        Issuer: /C=US/ST=New York/L=New York/O=Example/OU=OPS/CN=ca.example.net/emailAddress=root@ca.example.net
        Last Update: Jul  8 06:09:55 2019 GMT
        Next Update: Aug  7 06:09:55 2019 GMT
        CRL extensions:
            X509v3 CRL Number:
                0
No Revoked Certificates.
    Signature Algorithm: sha256WithRSAEncryption
         45:c2:cd:91:e0:cc:9d:37:95:c2:76:dc:39:c2:ef:d5:7c:af:
         1f:2f:61:fd:24:d5:b9:42:54:d3:dc:63:df:c5:ed:47:c2:df:
         fd:1d:c3:ef:d7:07:54:c2:49:e6:c3:5b:87:61:29:67:6d:bd:
         c5:a5:93:6d:4f:4e:5e:e6:41:7f:cc:2e:9c:7d:c7:ed:d7:64:
         81:93:91:17:ea:a1:26:a8:1b:c9:e2:35:a9:99:a9:19:a5:77:
         f3:b7:c9:a5:4c:19:fd:ed:6a:73:31:1a:36:46:9b:68:e9:42:
         0b:d2:2c:f2:8f:95:7b:26:89:2c:20:93:ab:57:a9:dc:c0:98:
         fc:c0:3d:d7:9b:ad:b1:81:d7:a1:ef:0c:b3:0f:fe:0a:3c:76:
         0d:40:0c:09:92:c4:01:84:82:b5:a2:85:ec:17:da:f7:2b:78:
         23:b8:5d:cc:15:f8:37:dd:d5:6e:5f:42:5c:7e:bd:7a:87:46:
         ab:d0:c5:ac:3a:f7:bb:84:57:16:0e:80:75:9f:cb:41:6f:af:
         ed:34:81:d1:c0:64:06:00:99:72:cf:ce:13:8d:2f:8a:4b:1c:
         43:ef:3c:e3:9f:b1:c4:df:b1:77:41:45:5e:58:c0:ae:a6:b4:
         4a:87:e6:c6:c6:3c:3d:35:e1:18:ed:fb:15:23:05:72:46:4e:
         b6:a2:fe:da
```

### HTTPS 
#### Generate Private key
```bash
# openssl genrsa -out web1.example.com.key 2048
Generating RSA private key, 2048 bit long modulus
..+++
.....+++
e is 65537 (0x10001)
```

#### Generate Cert Request
```bash
# openssl req -new -sha256 -key web1.example.com.key -out web1.example.com.csr
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [US]:US
State or Province Name (full name) [New York]:New York
Locality Name (eg, city) [New York]:New York
Organization Name (eg, company) [Example]:Example
Organizational Unit Name (eg, section) []:test
Common Name (eg, your name or your server's hostname) []:web1.example.com
Email Address []:root@web1.example.com

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:
```

#### Sign Cert 
```bash
# openssl ca -in web1.example.com.csr -out web1.example.com.crt
Using configuration from /etc/pki/tls/openssl.cnf
Enter pass phrase for /etc/pki/CA/private/my-ca.key:
Check that the request matches the signature
Signature ok
Certificate Details:
        Serial Number: 2 (0x2)
        Validity
            Not Before: Apr 11 16:06:13 2020 GMT
            Not After : Apr 11 16:06:13 2021 GMT
        Subject:
            countryName               = US
            stateOrProvinceName       = New York
            organizationName          = Example
            organizationalUnitName    = test
            commonName                = web1.example.com
            emailAddress              = root@web1.example.com
        X509v3 extensions:
            X509v3 Basic Constraints:
                CA:FALSE
            Netscape Comment:
                OpenSSL Generated Certificate
            X509v3 Subject Key Identifier:
                17:C3:6B:FF:4F:F3:8B:71:98:24:BF:6D:B1:46:2C:8A:B2:C1:C7:EB
            X509v3 Authority Key Identifier:
                keyid:F2:CF:04:95:36:A0:35:FF:1F:71:64:83:AB:46:F0:4F:21:E1:69:10

Certificate is to be certified until Apr 11 16:06:13 2021 GMT (365 days)
Sign the certificate? [y/n]:y


1 out of 1 certificate requests certified, commit? [y/n]y
Write out database with 1 new entries
Data Base Updated
```

#### Update http config
```bash
# yum install mod_ssl

# cat >> /etc/httpd/conf/httpd.conf << EOF
LoadModule ssl_module modules/mod_ssl.so

Listen 443
<VirtualHost *:443>
   DocumentRoot /var/www/html
   <Directory /var/www/html>
     AllowOverride All
     order allow,deny
     allow from all
   </Directory>

   ServerName web1.example.com
   SSLEngine on
   SSLCertificateFile /etc/httpd/https/web1.example.com.crt
   SSLCertificateKeyFile /etc/httpd/https/web1.example.com.key

#   SSLVerifyClient require
   SSLVerifyDepth 1
   SSLCACertificateFile /etc/httpd/https/my-ca.crt
   CustomLog logs/ssl_request_log \
          "%t %h %{SSL_PROTOCOL}x %{SSL_CIPHER}x \"%r\" %b"
</VirtualHost>
EOF

# mv /etc/httpd/conf.d/ssl.conf{,.bak}

# mkdir /etc/httpd/https -p

# cp /root/web1.example.com* /etc/httpd/https/

# systemctl restart httpd
```

#### Verify https connection
```bash
# curl --cacert /etc/pki/CA/my-ca.crt https://web1.example.com
web1.example.com

 # curl -k https://web1.example.com
web1.example.com

# tailf /etc/httpd/logs/ssl_request_log
...
[11/Apr/2020:16:26:48 +0000] 192.168.0.40 TLSv1.2 ECDHE-RSA-AES256-GCM-SHA384 "GET / HTTP/1.1" 19
```

{% include links.html %}
