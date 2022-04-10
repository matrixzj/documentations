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

### Check Key/Cert Info
```bash
# openssl rsa -in /etc/pki/CA/private/my-ca.key -text -noout

# openssl x509 -in /etc/pki/CA/my-ca.crt -text -noout
```

## Sign Cert for others 
### Generate private key
```bash
$ openssl genrsa -out master01.example.net.key 2048
Generating RSA private key, 2048 bit long modulus
.....................................................+++
..+++
e is 65537 (0x10001)
```

### Generate Cert Sign Request (including 'subjectAltName')
```bash
$ cat master01.cnf
[ req ]
distinguished_name      = req_distinguished_name
req_extensions = v3_req # The extensions to add to a certificate request

[ req_distinguished_name ]
countryName                     = Country Name (2 letter code)
stateOrProvinceName             = State or Province Name (full name)
localityName                    = Locality Name (eg, city)
organizationName                = Organization Name (eg, company)
organizationalUnitName          = Organizational Unit Name (eg, section)
commonName                      = Common Name (eg, your name or your server\'s hostname)
emailAddress                    = Email Address


[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment, keyAgreement
subjectAltName = @alt_names

[alt_names]
DNS.1 = master01.example.net
IP.1 = 192.168.0.69
IP.2 = 127.0.0.1

$ openssl req -new -out master01.example.net.csr -key master01.example.net.key -config master01.cnf
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) []:CN
State or Province Name (full name) []:Beijing
Locality Name (eg, city) []:Beijing
Organization Name (eg, company) []:MA
Organizational Unit Name (eg, section) []:Matrix
Common Name (eg, your name or your server's hostname) []:master01.example.net
Email Address []:root@master01.example.net
```

### Check Cert Request Content

```bash
 $ openssl req -in master01.example.net.csr -noout -text
Certificate Request:
    Data:
        Version: 0 (0x0)
        Subject: C=CN, ST=Beijing, L=Beijing, O=MA, OU=Matrix, CN=master01.example.net/emailAddress=root@master01.example.net
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (2048 bit)
                Modulus:
                    00:cb:47:02:5f:62:a7:85:be:0c:45:85:1e:34:28:
                    aa:4e:64:22:1f:65:b7:63:ab:6c:81:17:ce:ec:00:
                    b8:37:1c:c2:74:9e:ec:60:16:d6:33:67:ee:b4:f7:
                    67:52:e5:12:dd:52:af:d8:e4:cc:96:8f:3c:f6:f7:
                    d3:74:b9:10:34:38:53:51:e7:37:23:4f:99:c1:93:
                    e1:bd:5c:fe:bf:0a:8f:26:15:56:3c:f6:09:9e:25:
                    bc:d4:86:ad:4f:d5:43:19:64:6b:d7:10:7e:44:a6:
                    f9:7e:31:81:14:dd:8b:6e:f4:29:c2:e6:cd:ff:b8:
                    a1:30:53:ad:7a:dc:1a:88:09:6e:06:c0:02:16:0d:
                    7f:66:f0:55:77:de:f9:c2:5d:9d:64:04:23:83:16:
                    ca:4b:00:31:3f:48:d1:75:c2:71:b2:4b:3b:ec:8f:
                    15:dc:53:b6:42:3e:35:2b:d6:df:d2:a5:0c:8e:e3:
                    b6:1b:8b:b9:47:71:53:b1:3c:22:79:3c:66:ef:90:
                    c2:8b:32:f3:08:61:bd:68:23:75:23:9b:59:93:f1:
                    41:7d:15:4a:71:f2:8a:c4:fd:c7:f5:ba:bf:4a:eb:
                    5c:7c:5e:db:b4:8c:f8:56:40:e6:e8:dc:a6:28:5b:
                    55:ba:ed:73:a7:2c:f0:d9:91:19:dc:4d:99:11:d7:
                    bb:f1
                Exponent: 65537 (0x10001)
        Attributes:
        Requested Extensions:
            X509v3 Basic Constraints:
                CA:FALSE
            X509v3 Key Usage:
                Digital Signature, Non Repudiation, Key Encipherment, Key Agreement
            X509v3 Subject Alternative Name:
                DNS:master01.example.net, IP Address:192.168.0.69, IP Address:127.0.0.1
    Signature Algorithm: sha256WithRSAEncryption
         92:83:a0:c2:11:90:e4:5a:3f:d3:f9:52:65:f5:06:ff:aa:00:
         8b:5c:80:f4:67:64:9b:f5:58:cd:8b:58:54:30:a0:2a:47:1e:
         76:b7:fd:af:63:d9:f6:3d:ed:f5:14:1c:d0:36:8b:60:a3:6b:
         de:81:b4:aa:77:70:4f:c6:f4:e7:8c:ea:80:b2:02:98:5e:71:
         3c:8c:b8:38:3f:cc:92:4d:ef:74:19:81:7d:0c:d9:21:e7:e7:
         b9:d6:f9:64:35:32:c4:d3:ac:2e:8e:25:0e:e0:57:03:18:4d:
         2c:25:f1:d3:9f:7b:c2:a9:d6:5a:c7:06:42:9d:ac:93:21:e5:
         c1:68:89:c7:3e:5c:eb:48:a0:0c:47:a9:a6:64:d2:ae:37:c5:
         98:28:d2:2f:3d:7c:54:ce:09:cc:36:e7:8a:b0:b1:b8:a1:d9:
         d5:03:e2:21:4b:7f:0b:8c:93:4c:20:55:80:1a:f2:a1:a5:b7:
         8e:c5:57:bd:00:08:b5:cc:2b:56:a7:30:a2:98:e2:10:64:34:
         7f:16:4b:5b:ff:74:5c:1b:8c:9a:6e:b7:a6:00:e9:54:17:6a:
         66:c4:5e:da:24:12:2c:fb:da:93:1c:c8:ae:1d:1e:ec:c8:23:
         ac:3d:38:65:9d:c8:fa:3a:67:32:6b:6e:75:2f:f9:3d:69:e3:
         d2:1e:b0:fa
```

### Sign a cert based on request
```
$ cat master01.cnf
[ ca ]
default_ca      = CA_default            # The default ca section

####################################################################
[ CA_default ]

dir             = /etc/pki/CA           # Where everything is kept
certs           = $dir/certs            # Where the issued certs are kept
crl_dir         = $dir/crl              # Where the issued crl are kept
database        = $dir/index.txt        # database index file.
new_certs_dir   = $dir/newcerts         # default place for new certs.
certificate     = $dir/my-ca.crt        # The CA certificate
serial          = $dir/serial           # The current serial number
crlnumber       = $dir/crlnumber        # the current crl number
crl             = $dir/crl.pem          # The current CRL
private_key     = $dir/private/my-ca.key # The private key
RANDFILE        = $dir/private/.rand    # private random number file
x509_extensions = usr_cert              # The extentions to add to the cert
name_opt        = ca_default            # Subject Name options
cert_opt        = ca_default            # Certificate field options
default_days    = 365                   # how long to certify for
default_crl_days= 30                    # how long before next CRL
default_md      = sha256                # use SHA-256 by default
preserve        = no                    # keep passed DN ordering
policy          = policy_match

[ policy_match ]
countryName             = match
stateOrProvinceName     = match
organizationName        = match
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional

[ usr_cert ]
basicConstraints=CA:FALSE
nsComment                       = "OpenSSL Generated Certificate"
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid,issuer
subjectAltName = @alt_names

[alt_names]
DNS.1 = master01.example.net
IP.1 = 192.168.0.69
IP.2 = 127.0.0.1

$ sudo openssl ca -in master01.example.net.csr -out master01.example.net.crt -config master01.cnf
Using configuration from master01.cnf
Enter pass phrase for /etc/pki/CA/private/my-ca.key:
Check that the request matches the signature
Signature ok
Certificate Details:
        Serial Number: 7 (0x7)
        Validity
            Not Before: Apr 10 19:37:01 2022 GMT
            Not After : Apr 10 19:37:01 2023 GMT
        Subject:
            countryName               = CN
            stateOrProvinceName       = Beijing
            organizationName          = MA
            organizationalUnitName    = Matrix
            commonName                = master01.example.net
            emailAddress              = root@master01.example.net
        X509v3 extensions:
            X509v3 Basic Constraints:
                CA:FALSE
            Netscape Comment:
                OpenSSL Generated Certificate
            X509v3 Subject Key Identifier:
                AE:C0:33:C2:D4:6C:83:8A:09:1F:13:A6:1A:A5:04:78:62:52:F6:B5
            X509v3 Authority Key Identifier:
                keyid:7C:7D:10:0E:BF:A1:FB:30:1B:58:8A:51:1F:E2:80:B7:7D:02:35:87

            X509v3 Subject Alternative Name:
                DNS:master01.example.net, IP Address:192.168.0.69, IP Address:127.0.0.1
Certificate is to be certified until Apr 10 19:37:01 2023 GMT (365 days)
Sign the certificate? [y/n]:y


1 out of 1 certificate requests certified, commit? [y/n]y
Write out database with 1 new entries
Data Base Updated
```

### Check Cert content
```bash
$ openssl x509 -in master01.example.net.crt -text -noout
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number: 7 (0x7)
    Signature Algorithm: sha256WithRSAEncryption
        Issuer: C=CN, ST=Beijing, L=Beijing, O=MA, OU=Matrix, CN=ca.example.net/emailAddress=root@ca.example.net
        Validity
            Not Before: Apr 10 19:37:01 2022 GMT
            Not After : Apr 10 19:37:01 2023 GMT
        Subject: C=CN, ST=Beijing, O=MA, OU=Matrix, CN=master01.example.net/emailAddress=root@master01.example.net
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (2048 bit)
                Modulus:
                    00:cb:47:02:5f:62:a7:85:be:0c:45:85:1e:34:28:
                    aa:4e:64:22:1f:65:b7:63:ab:6c:81:17:ce:ec:00:
                    b8:37:1c:c2:74:9e:ec:60:16:d6:33:67:ee:b4:f7:
                    67:52:e5:12:dd:52:af:d8:e4:cc:96:8f:3c:f6:f7:
                    d3:74:b9:10:34:38:53:51:e7:37:23:4f:99:c1:93:
                    e1:bd:5c:fe:bf:0a:8f:26:15:56:3c:f6:09:9e:25:
                    bc:d4:86:ad:4f:d5:43:19:64:6b:d7:10:7e:44:a6:
                    f9:7e:31:81:14:dd:8b:6e:f4:29:c2:e6:cd:ff:b8:
                    a1:30:53:ad:7a:dc:1a:88:09:6e:06:c0:02:16:0d:
                    7f:66:f0:55:77:de:f9:c2:5d:9d:64:04:23:83:16:
                    ca:4b:00:31:3f:48:d1:75:c2:71:b2:4b:3b:ec:8f:
                    15:dc:53:b6:42:3e:35:2b:d6:df:d2:a5:0c:8e:e3:
                    b6:1b:8b:b9:47:71:53:b1:3c:22:79:3c:66:ef:90:
                    c2:8b:32:f3:08:61:bd:68:23:75:23:9b:59:93:f1:
                    41:7d:15:4a:71:f2:8a:c4:fd:c7:f5:ba:bf:4a:eb:
                    5c:7c:5e:db:b4:8c:f8:56:40:e6:e8:dc:a6:28:5b:
                    55:ba:ed:73:a7:2c:f0:d9:91:19:dc:4d:99:11:d7:
                    bb:f1
                Exponent: 65537 (0x10001)
        X509v3 extensions:
            X509v3 Basic Constraints:
                CA:FALSE
            Netscape Comment:
                OpenSSL Generated Certificate
            X509v3 Subject Key Identifier:
                AE:C0:33:C2:D4:6C:83:8A:09:1F:13:A6:1A:A5:04:78:62:52:F6:B5
            X509v3 Authority Key Identifier:
                keyid:7C:7D:10:0E:BF:A1:FB:30:1B:58:8A:51:1F:E2:80:B7:7D:02:35:87

            X509v3 Subject Alternative Name:
                DNS:master01.example.net, IP Address:192.168.0.69, IP Address:127.0.0.1
    Signature Algorithm: sha256WithRSAEncryption
         33:86:66:51:b5:16:2f:1e:b4:3e:12:96:e0:dc:52:5b:a2:f3:
         84:10:f3:4c:e9:c9:b6:eb:20:06:fd:0a:a4:88:6f:cd:2e:21:
         8d:b5:1e:3c:da:cd:b4:e0:df:11:b7:03:91:21:b7:ea:b5:70:
         7b:af:b8:40:a8:db:9f:65:4d:87:2b:d3:83:c9:cd:82:dd:f9:
         9e:b9:41:fa:3a:c1:25:64:a5:c3:ad:e4:6c:03:5c:be:e6:d4:
         1f:77:8f:ac:1f:93:6c:7d:71:ff:97:8e:7f:ed:78:7b:db:9f:
         c0:33:40:60:26:ca:43:6b:f6:4d:c2:83:68:27:7d:a4:e4:8f:
         aa:f7:77:eb:07:83:6d:9d:7b:4e:ed:41:1d:3a:b8:a9:52:43:
         29:3b:cd:ff:e4:74:ad:ba:05:a8:33:27:24:ef:8f:d3:7b:67:
         a4:03:98:62:9e:de:85:62:e2:e0:de:4e:da:8d:9e:e6:22:a6:
         2d:ed:57:0c:5a:fe:66:76:57:73:cc:40:03:ce:6f:5e:81:ff:
         18:43:0e:79:24:b5:fa:b1:61:48:fd:15:96:df:3b:3e:89:d8:
         53:de:86:fd:fb:de:36:75:f5:07:bc:8d:d0:87:61:64:4d:f8:
         8d:1f:c6:ad:a8:56:59:ea:00:0d:c0:46:34:e2:bd:b2:29:d1:
         39:6f:78:a4
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
