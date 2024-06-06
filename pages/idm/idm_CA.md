---
title: CA(Certificate Authority)
tags: [idm]
keywords: certs, tls, ssl
last_updated: Jun 6, 2024
summary: "Self-signed CA Setup"
sidebar: mydoc_sidebar
permalink: idm_ca.html
folder: idm
---

CA(Certificate Authority)
======

## CA
### Certs Path Config  
Open `/etc/pki/tls/openssl.cnf`, find the section labeled `[ CA_default ]`, and edit as the following:  
```bash
$ sudo cp /etc/pki/tls/openssl.cnf{,.orig}
$ cat <<EOF | sudo tee /etc/pki/tls/openssl.cnf
HOME                    = .
RANDFILE                = \$ENV::HOME/.rnd
oid_section             = new_oids

[ new_oids ]
tsa_policy1 = 1.2.3.4.1
tsa_policy2 = 1.2.3.4.5.6
tsa_policy3 = 1.2.3.4.5.7

[ ca ]
default_ca      = CA_default            # The default ca section

[ CA_default ]
dir             = /etc/pki/CA           # Where everything is kept
certs           = \$dir/certs           # Where the issued certs are kept
crl_dir         = \$dir/crl             # Where the issued crl are kept
database        = \$dir/index.txt       # database index file.
                                        # several ctificates with same subject.
new_certs_dir   = \$dir/newcerts        # default place for new certs.
certificate     = \$dir/ca.crt          # The CA certificate
serial          = \$dir/serial          # The current serial number
crlnumber       = \$dir/crlnumber       # the current crl number
                                        # must be commented out to leave a V1 CRL
crl             = \$dir/ca.crl          # The current CRL
private_key     = \$dir/private/ca.key  # The private key
RANDFILE        = \$dir/private/.rand   # private random number file
x509_extensions = v3_ca                 # The extentions to add to the cert
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

[ req ]
default_bits            = 2048
default_md              = sha256
default_keyfile         = privkey.pem
distinguished_name      = req_distinguished_name
attributes              = req_attributes
x509_extensions         = v3_ca # The extentions to add to the self signed cert
string_mask             = utf8only

[ req_distinguished_name ]
countryName                     = Country Name (2 letter code)
countryName_default             = CN
countryName_min                 = 2
countryName_max                 = 2
stateOrProvinceName             = State or Province Name (full name)
stateOrProvinceName_default     = Beijing
localityName                    = Locality Name (eg, city)
localityName_default            = Beijing
0.organizationName              = Organization Name (eg, company)
0.organizationName_default      = Example Ltd
organizationalUnitName          = Organizational Unit Name (eg, section)
commonName                      = Common Name (eg, your name or your server\'s hostname)
commonName_max                  = 64
emailAddress                    = Email Address
emailAddress_max                = 64

[ req_attributes ]
challengePassword               = A challenge password
challengePassword_min           = 4
challengePassword_max           = 20
unstructuredName                = An optional company name

[ v3_ca ]
subjectKeyIdentifier            = hash
authorityKeyIdentifier          = keyid:always,issuer
basicConstraints                = CA:true
EOF  
```

### Certs Info
The `[ req_distinguished_name ]` section lists several default options for authorized certs
```bash
countryName_default = CN
stateOrProvinceName_default = Beijing
localityName_default = Beijing
0.organizationName_default = Example Ltd
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

### Create all directories needed
```
$ sudo mkdir /etc/pki/CA/{certs,crl,newcerts}
```

### Create an empty certificate index:
```
$ sudo touch /etc/pki/CA/index.txt
```

### In addition, create a file to indicate the next certificate serial number to be issued:
```
$ echo 01 | sudo tee /etc/pki/CA/serial
```

## RootCA
### Generate RootCA Private Key
```
$ sudo openssl genrsa -out /etc/pki/CA/private/ca.key -des3 2048
Enter pass phrase for /etc/pki/CA/private/ca.key:
Verifying - Enter pass phrase for /etc/pki/CA/private/ca.key:

$ sudo chmod 600 /etc/pki/CA/private/ca.key
```

### Generate RootCA Public Cert
```bash
$ sudo openssl req -new -x509 -key /etc/pki/CA/private/ca.key -days 3650 -subj '/C=CN/ST=Beijing/L=Beijing/O=Example Ltd/OU=RootCA/CN=RootCA/emailAddress=root@localhost' -out /etc/pki/CA/ca.crt
Enter pass phrase for /etc/pki/CA/private/ca.key:
```

### Check RootCA Private Key / Public Cert
```bash
$ sudo openssl rsa -in /etc/pki/CA/private/ca.key -text -noout

$ openssl x509 -in /etc/pki/CA/ca.crt -text -noout
```

## Level-1 CA
Note: It will be signed by `RootCA`  
### Config
```bash
$ mkdir -p CA-Level1

$ cat <<EOF> CA-Level1/CA-Level1.cnf
[ req ]
distinguished_name      = req_distinguished_name
req_extensions          = v3_ca # The extensions to add to a certificate request

[ req_distinguished_name ]
countryName                     = Country Name (2 letter code)
stateOrProvinceName             = State or Province Name (full name)
localityName                    = Locality Name (eg, city)
organizationName                = Organization Name (eg, company)
organizationalUnitName          = Organizational Unit Name (eg, section)
commonName                      = Common Name (eg, your name or your server\'s hostname)
emailAddress                    = Email Address

[ v3_ca ]
subjectKeyIdentifier            = hash
basicConstraints                = CA:true, pathlen:1
keyUsage                        = cRLSign, keyCertSign
EOF
```

### Generate Level-1 CA Private Key
```bash
$ openssl genrsa -out CA-Level1/CA-Level1.key -des3 2048
```

### Generate Level-1 CA Cert Sign Request
```bash
$ openssl req -new -out CA-Level1/CA-Level1.csr -key CA-Level1/CA-Level1.key -config CA-Level1/CA-Level1.cnf -subj '/C=CN/ST=Beijing/L=Beijing/O=Example Ltd/OU=CA-Level1/CN=CA-Level1/emailAddress=root@localhost'
```
 
### Sign Level-1 CA Public Cert
```bash
$ sudo openssl ca -in CA-Level1/CA-Level1.csr -out CA-Level1/CA-Level1.crt -config CA-Level1/CA-Level1.cnf
Using configuration from CA-Level1/CA-Level1.cnf
Enter pass phrase for /etc/pki/CA/private/ca.key:
Check that the request matches the signature
Signature ok
Certificate Details:
        Serial Number: 1 (0x1)
        Validity
            Not Before: Jun  6 05:51:10 2024 GMT
            Not After : Jun  6 05:51:10 2025 GMT
        Subject:
            countryName               = CN
            stateOrProvinceName       = Beijing
            organizationName          = Example Ltd
            organizationalUnitName    = CA-Level1
            commonName                = CA-Level1
            emailAddress              = root@localhost
        X509v3 extensions:
            X509v3 Subject Key Identifier:
                EF:23:28:B5:46:52:86:AB:8D:05:95:5E:4F:A4:8F:11:49:F5:7F:F2
            X509v3 Basic Constraints:
                CA:TRUE, pathlen:1
            X509v3 Key Usage:
                Certificate Sign, CRL Sign
Certificate is to be certified until Jun  6 05:51:10 2025 GMT (365 days)
Sign the certificate? [y/n]:y


1 out of 1 certificate requests certified, commit? [y/n]y
Write out database with 1 new entries
Data Base Updated
```

### Check Level-1 CA Private Key / Public Cert / Cert Sign Request
```bash
$ openssl rsa -in CA-Level1/CA-Level1.key -noout -text

$ openssl x509 -in CA-Level1/CA-Level1.crt -noout -text

$ openssl req -inCA-Level1/ CA-Level1.csr -noout -text
```

## Level-2 CA
Note: It will be signed by `Level-1 CA`  
### Config
```bash
$ mkdir -p CA-Level2

$ cat <<EOF> CA-Level2/CA-Level2.cnf
[ req ]
distinguished_name      = req_distinguished_name
req_extensions          = v3_ca # The extensions to add to a certificate request

[ req_distinguished_name ]
countryName                     = Country Name (2 letter code)
stateOrProvinceName             = State or Province Name (full name)
localityName                    = Locality Name (eg, city)
organizationName                = Organization Name (eg, company)
organizationalUnitName          = Organizational Unit Name (eg, section)
commonName                      = Common Name (eg, your name or your server\'s hostname)
emailAddress                    = Email Address

[ v3_ca ]
subjectKeyIdentifier            = hash
basicConstraints                = CA:true, pathlen:0
keyUsage                        = cRLSign, keyCertSign
EOF
```

### Generate Level-2 CA Private Key
```bash
$ openssl genrsa -out CA-Level2/CA-Level2.key -des3 2048
```

### Generate Level-2 CA Cert Sign Request
```bash
$ openssl req -new -out CA-Level2/CA-Level2.csr -key CA-Level2/CA-Level2.key -config CA-Level2/CA-Level2.cnf -subj '/C=CN/ST=Beijing/L=Beijing/O=Example Ltd/OU=CA-Level2/CN=CA-Level2/emailAddress=root@localhost' -extensions v3_ca
```

### Sign Level-2 CA Public Cert
#### Config
```bash
$ mkdir -p CA-Level1/{certs,crl,newcerts}

$ touch CA-Level1/index.txt

$ echo 01 > CA-Level1/serial

$ cat <<EOF> CA-Level1/CA-Level1-Sign.cnf
[ ca ]
default_ca      = CA_default            # The default ca section

[ CA_default ]
dir             = $(pwd)/CA-Level1      # Where everything is kept
certs           = \$dir/certs           # Where the issued certs are kept
crl_dir         = \$dir/crl             # Where the issued crl are kept
database        = \$dir/index.txt       # database index file.
                                        # several ctificates with same subject.
new_certs_dir   = \$dir/newcerts        # default place for new certs.
certificate     = \$dir/CA-Level1.crt   # The CA certificate
serial          = \$dir/serial          # The current serial number
crlnumber       = \$dir/crlnumber       # the current crl number
                                        # must be commented out to leave a V1 CRL
crl             = \$dir/ca.crl          # The current CRL
private_key     = \$dir/CA-Level1.key   # The private key
RANDFILE        = \$dir/.rand           # private random number file
x509_extensions = v3_ca                 # The extentions to add to the cert
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

[ req ]
default_bits            = 2048
default_md              = sha256
default_keyfile         = privkey.pem
distinguished_name      = req_distinguished_name
attributes              = req_attributes
x509_extensions         = v3_ca # The extentions to add to the self signed cert
string_mask             = utf8only

[ req_distinguished_name ]
countryName                     = Country Name (2 letter code)
countryName_default             = CN
countryName_min                 = 2
countryName_max                 = 2
stateOrProvinceName             = State or Province Name (full name)
stateOrProvinceName_default     = Beijing
localityName                    = Locality Name (eg, city)
localityName_default            = Beijing
0.organizationName              = Organization Name (eg, company)
0.organizationName_default      = Example Ltd
organizationalUnitName          = Organizational Unit Name (eg, section)
commonName                      = Common Name (eg, your name or your server\'s hostname)
commonName_max                  = 64
emailAddress                    = Email Address
emailAddress_max                = 64

[ req_attributes ]
challengePassword               = A challenge password
challengePassword_min           = 4
challengePassword_max           = 20
unstructuredName                = An optional company name

[ v3_ca ]
subjectKeyIdentifier            = hash
authorityKeyIdentifier          = keyid:always,issuer
basicConstraints                = CA:true
EOF  
```

#### Cert Sign
```bash
$ openssl ca -in CA-Level2/CA-Level2.csr -out CA-Level2/CA-Level2.crt -config CA-Level1/CA-Level1-Sign.cnf
Using configuration from CA-Level1/CA-Level1-Sign.cnf
Enter pass phrase for /home/jun_zou/CA-Level1/CA-Level1.key:
Check that the request matches the signature
Signature ok
Certificate Details:
        Serial Number: 1 (0x1)
        Validity
            Not Before: Jun  6 06:18:27 2024 GMT
            Not After : Jun  6 06:18:27 2025 GMT
        Subject:
            countryName               = CN
            stateOrProvinceName       = Beijing
            organizationName          = Example Ltd
            organizationalUnitName    = CA-Level2
            commonName                = CA-Level2
            emailAddress              = root@localhost
        X509v3 extensions:
            X509v3 Subject Key Identifier:
                31:E6:BD:EE:23:45:39:A4:2E:05:7A:53:BC:66:46:D0:65:8E:DF:B2
            X509v3 Authority Key Identifier:
                keyid:EF:23:28:B5:46:52:86:AB:8D:05:95:5E:4F:A4:8F:11:49:F5:7F:F2

            X509v3 Basic Constraints:
                CA:TRUE
Certificate is to be certified until Jun  6 06:18:27 2025 GMT (365 days)
Sign the certificate? [y/n]:y


1 out of 1 certificate requests certified, commit? [y/n]y
Write out database with 1 new entries
Data Base Updated
```

## Server Cert
Note: It will be signed by `Level-2 CA`  
### Config
```bash
$ mkdir -p ecs-matrix-https-server 

$ cat <<EOF> ecs-matrix-https-server/ecs-matrix-https-server.cnf
[ req ]
distinguished_name              = req_distinguished_name
req_extensions                  = v3_req # The extensions to add to a certificate request

[ req_distinguished_name ]
countryName                     = Country Name (2 letter code)
stateOrProvinceName             = State or Province Name (full name)
localityName                    = Locality Name (eg, city)
organizationName                = Organization Name (eg, company)
organizationalUnitName          = Organizational Unit Name (eg, section)
commonName                      = Common Name (eg, your name or your server\'s hostname)
emailAddress                    = Email Address

[ v3_req ]
basicConstraints                = CA:FALSE
keyUsage                        = nonRepudiation, digitalSignature, keyEncipherment, keyAgreement
subjectAltName                  = @alt_names

[alt_names]
DNS.1                           = ecs-matrix-https-server
IP.1                            = 172.16.1.131
IP.2                            = 127.0.0.1
EOF
```

### Generate Server Private Key
```bash
$ openssl genrsa -out ecs-matrix-https-server.key 2048
```

### Generate Cert Sign Request (including 'subjectAltName')
```bash
$ openssl req -new -out ecs-matrix-https-server/ecs-matrix-https-server.csr -key ecs-matrix-https-server/ecs-matrix-https-server.key -config ecs-matrix-https-server/ecs-matrix-https-server.cnf -subj '/C=CN/ST=Beijing/L=Beijing/O=Example Ltd/OU=ecs-matrix-https-server/CN=ecs-matrix-https-server/emailAddress=root@localhost'
```

### Sign Server Public Cert
#### Config
```bash
$ mkdir -p CA-Level2/{certs,crl,newcerts}

$ touch CA-Level2/index.txt

$ echo 01 > CA-Level2/serial

$ cat <<EOF> CA-Level2/CA-Level2-Sign.cnf
[ ca ]
default_ca      = CA_default            # The default ca section

[ CA_default ]
dir             = $(pwd)/CA-Level2      # Where everything is kept
certs           = \$dir/certs           # Where the issued certs are kept
crl_dir         = \$dir/crl             # Where the issued crl are kept
database        = \$dir/index.txt       # database index file.
                                        # several ctificates with same subject.
new_certs_dir   = \$dir/newcerts        # default place for new certs.
certificate     = \$dir/CA-Level2.crt   # The CA certificate
serial          = \$dir/serial          # The current serial number
crlnumber       = \$dir/crlnumber       # the current crl number
                                        # must be commented out to leave a V1 CRL
crl             = \$dir/ca.crl          # The current CRL
private_key     = \$dir/CA-Level2.key   # The private key
RANDFILE        = \$dir/.rand           # private random number file
x509_extensions = v3_req                # The extentions to add to the cert
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

[ req ]
default_bits            = 2048
default_md              = sha256
default_keyfile         = privkey.pem
distinguished_name      = req_distinguished_name
attributes              = req_attributes
x509_extensions         = v3_ca # The extentions to add to the self signed cert
string_mask             = utf8only

[ req_distinguished_name ]
countryName                     = Country Name (2 letter code)
countryName_default             = CN
countryName_min                 = 2
countryName_max                 = 2
stateOrProvinceName             = State or Province Name (full name)
stateOrProvinceName_default     = Beijing
localityName                    = Locality Name (eg, city)
localityName_default            = Beijing
0.organizationName              = Organization Name (eg, company)
0.organizationName_default      = Example Ltd
organizationalUnitName          = Organizational Unit Name (eg, section)
commonName                      = Common Name (eg, your name or your server\'s hostname)
commonName_max                  = 64
emailAddress                    = Email Address
emailAddress_max                = 64

[ req_attributes ]
challengePassword               = A challenge password
challengePassword_min           = 4
challengePassword_max           = 20
unstructuredName                = An optional company name

[ v3_req ]
basicConstraints                = CA:FALSE
keyUsage                        = nonRepudiation, digitalSignature, keyEncipherment, keyAgreement
subjectAltName                  = @alt_names

[alt_names]
DNS.1                           = ecs-matrix-https-server
IP.1                            = 172.16.1.131
IP.2                            = 127.0.0.1
EOF
```

#### Sign Cert
```bash
$ openssl ca -in ecs-matrix-https-server/ecs-matrix-https-server.csr -out ecs-matrix-https-server/ecs-matrix-https-server.crt -config CA-Level2/CA-Level2-Sign.cnf
UUsing configuration from CA-Level1-Sign.cnf
Enter pass phrase for /home/jun_zou/CA-Level1/private/CA-Level1.key:
Check that the request matches the signature
Signature ok
Certificate Details:
        Serial Number: 2 (0x2)
        Validity
            Not Before: Jun  5 14:23:26 2024 GMT
            Not After : Jun  5 14:23:26 2025 GMT
        Subject:
            countryName               = CN
            stateOrProvinceName       = Beijing
            organizationName          = Example Ltd
            organizationalUnitName    = ecs-matrix-https-server
            commonName                = ecs-matrix-https-server
            emailAddress              = root@localhost
        X509v3 extensions:
            X509v3 Basic Constraints:
                CA:FALSE
            Netscape Comment:
                OpenSSL Generated Certificate
            X509v3 Subject Key Identifier:
                D7:F6:98:80:08:22:81:2C:F0:17:8F:1E:E9:BC:08:7C:30:ED:19:A9
            X509v3 Authority Key Identifier:
                keyid:1D:E0:AE:34:D9:B1:E7:EE:31:67:67:ED:14:C3:65:A5:B2:57:2C:CF

Certificate is to be certified until Jun  5 14:23:26 2025 GMT (365 days)
Sign the certificate? [y/n]:y


1 out of 1 certificate requests certified, commit? [y/n]y
Write out database with 1 new entries
Data Base Updated
```

### Revoke a cert
```bash
$ openssl ca -revoke /etc/pki/CA/newcerts/02.pem
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

## HTTPS 
### HTTP Config
```bash
$ sudo yum install -y mod_ssl

$ sudo cp /etc/httpd/conf.d/ssl.conf{,.orig}

$ cat <<EOF | sudo tee /etc/httpd/conf.d/ssl.conf
Listen 443 https

SSLPassPhraseDialog exec:/usr/libexec/httpd-ssl-pass-dialog

SSLSessionCache         shmcb:/run/httpd/sslcache(512000)
SSLSessionCacheTimeout  300

SSLRandomSeed startup file:/dev/urandom  256
SSLRandomSeed connect builtin

SSLCryptoDevice builtin

<VirtualHost *:443>
    DocumentRoot /var/www/html
    <Directory /var/www/html>
        AllowOverride All
        order allow,deny
        allow from all
    </Directory>
    ErrorLog logs/ssl_error_log
    TransferLog logs/ssl_access_log
    CustomLog logs/ssl_request_log "%t %h %{SSL_PROTOCOL}x %{SSL_CIPHER}x \"%r\" %b"
    LogLevel warn

    ServerName ecs-matrix-https-server
    SSLEngine on

    SSLProtocol all -SSLv2 -SSLv3

    SSLCipherSuite HIGH:3DES:!aNULL:!MD5:!SEED:!IDEA

    SSLCertificateFile /etc/httpd/certs/ecs-matrix-https-server.crt
    SSLCertificateKeyFile /etc/httpd/certs/ecs-matrix-https-server.key
</VirtualHost>
EOF

sudo systemctl restart httpd
```

### Verify https connection
```bash
$ curl --cacert CA-Level2/CA-Level2.crt https://ecs-matrix-https-server
ecs-matrix-https-server

$ curl --cacert /etc/pki/CA/ca.crt https://ecs-matrix-https-server 2>/dev/null

$ echo $?
60
```

```bash
$ tailf /etc/httpd/logs/ssl_request_log
...
[06/Jun/2024:07:42:00 +0000] 172.16.1.245 TLSv1.2 ECDHE-RSA-AES256-GCM-SHA384 "GET / HTTP/1.1" 24
```

### Alternative HTTP Config
include cert chain in config
```bash
$ sed -n -E '/BEGIN/,/END/p' CA-Level1/CA-Level1.crt CA-Level2/CA-Level2.crt > ca-chain.crt
```

```bash
$ sudo sed -i.bak-cert-chain '/SSLCertificateKeyFile/a\    SSLCertificateChainFile /etc/httpd/certs/ca-chain.crt' /etc/httpd/conf.d/ssl.conf

$ diff -Nru /etc/httpd/conf.d/ssl.conf /etc/httpd/conf.d/ssl.conf.bak-cert-chain
--- /etc/httpd/conf.d/ssl.conf  2024-06-06 07:48:16.738244189 +0000
+++ /etc/httpd/conf.d/ssl.conf.bak-cert-chain   2024-06-06 06:40:15.764740916 +0000
@@ -31,5 +31,4 @@

     SSLCertificateFile /etc/httpd/certs/ecs-matrix-https-server.crt
     SSLCertificateKeyFile /etc/httpd/certs/ecs-matrix-https-server.key
-    SSLCertificateChainFile /etc/httpd/certs/ca-chain.crt
 </VirtualHost>

$ sudo systemctl restart httpd
```

### Verify https connection
```bash
$ curl --cacert /etc/pki/CA/ca.crt https://ecs-matrix-https-server
ecs-matrix-https-server
```

{% include links.html %}