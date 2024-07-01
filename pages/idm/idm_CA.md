---
title: CA(Certificate Authority)
tags: [idm]
keywords: certs, tls, ssl
last_updated: Jun 7, 2024
summary: "Self-signed CA Setup"
sidebar: mydoc_sidebar
permalink: idm_ca.html
folder: idm
---

CA(Certificate Authority)
======

## General
### Config  
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
certificate     = \$dir/root-ca.crt          # The CA certificate
serial          = \$dir/serial          # The current serial number
crlnumber       = \$dir/crlnumber       # the current crl number
                                        # must be commented out to leave a V1 CRL
crl             = \$dir/root-ca.crl          # The current CRL
private_key     = \$dir/private/root-ca.key  # The private key
RANDFILE        = \$dir/private/.rand   # private random number file
x509_extensions = root_ca                 # The extentions to add to the cert
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
x509_extensions         = root_ca # The extentions to add to the self signed cert
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

[ root_ca ]
subjectKeyIdentifier            = hash
authorityKeyIdentifier          = keyid:always,issuer
basicConstraints                = CA:true
crlDistributionPoints           = @crl_section

[ crl_section ]
URI.1                           = http://ecs-matrix-ca/root-ca.crl

[ level1_ca ]
subjectKeyIdentifier            = hash
authorityKeyIdentifier          = keyid:always,issuer
basicConstraints                = CA:true, pathlen:1
keyUsage                        = cRLSign, keyCertSign
crlDistributionPoints           = @crl_section

[ crl_section ]
URI.1                           = http://ecs-matrix-ca/level1-ca.crl
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
```bash
$ sudo mkdir /etc/pki/CA/{certs,crl,newcerts}
```

### Create an empty certificate index
```bash
$ sudo touch /etc/pki/CA/index.txt
```

### Create a serial number file 
to indicate the next certificate serial number to be issued
```bash
$ echo 01 | sudo tee /etc/pki/CA/serial
```

## RootCA
### Generate RootCA Private Key
```bash
$ sudo openssl genrsa -out /etc/pki/CA/private/root-ca.key -des3 2048
Enter pass phrase for /etc/pki/CA/private/root-ca.key:
Verifying - Enter pass phrase for /etc/pki/CA/private/root-ca.key:

$ sudo chmod 600 /etc/pki/CA/private/root-ca.key
```

### Generate RootCA Public Cert
```bash
$ sudo openssl req -new -x509 -key /etc/pki/CA/private/root-ca.key -days 3650 -subj '/C=CN/ST=Beijing/L=Beijing/O=Example Ltd/OU=RootCA/CN=RootCA/emailAddress=root@localhost' -out /etc/pki/CA/root-ca.crt
Enter pass phrase for /etc/pki/CA/private/root-ca.key:
```

## Level-1 CA
Note: It will be signed by `RootCA`  
### Config
```bash
$ mkdir -p CA-Level1

# Config for Level-1 CA CSR Generation
$ cat <<EOF> CA-Level1/CA-Level1.cnf
[ req ]
distinguished_name      = req_distinguished_name
req_extensions          = leve1_ca # The extensions to add to a certificate request

[ req_distinguished_name ]
countryName                     = Country Name (2 letter code)
stateOrProvinceName             = State or Province Name (full name)
localityName                    = Locality Name (eg, city)
organizationName                = Organization Name (eg, company)
organizationalUnitName          = Organizational Unit Name (eg, section)
commonName                      = Common Name (eg, your name or your server\'s hostname)
emailAddress                    = Email Address

[ leve1_ca ]
subjectKeyIdentifier            = hash
basicConstraints                = CA:true, pathlen:1
keyUsage                        = cRLSign, keyCertSign
crlDistributionPoints           = @crl_section

[ crl_section ]
URI.1                           = http://ecs-matrix-ca/level1-ca.crl
EOF
```

### Generate Level-1 CA Private Key
```bash
$ openssl genrsa -out CA-Level1/CA-Level1.key -des3 2048
```

### Generate Level-1 CA Cert Sign Request
```bash
$ openssl req -new -out CA-Level1/CA-Level1.csr -key CA-Level1/CA-Level1.key -config CA-Level1/CA-Level1.cnf -subj '/C=CN/ST=Beijing/L=Beijing/O=Example Ltd/OU=CA-Level1/CN=CA-Level1/emailAddress=root@localhost'
Enter pass phrase for CA-Level1/CA-Level1.key:
```
 
### Sign Level-1 CA Public Cert
```bash
$ $ sudo openssl ca -in CA-Level1/CA-Level1.csr -out CA-Level1/CA-Level1.crt -extensions level1_ca
Using configuration from /etc/pki/tls/openssl.cnf
Enter pass phrase for /etc/pki/CA/private/root-ca.key:
Check that the request matches the signature
Signature ok
Certificate Details:
        Serial Number: 1 (0x1)
        Validity
            Not Before: Jun  7 06:59:16 2024 GMT
            Not After : Jun  7 06:59:16 2025 GMT
        Subject:
            countryName               = CN
            stateOrProvinceName       = Beijing
            organizationName          = Example Ltd
            organizationalUnitName    = CA-Level1
            commonName                = CA-Level1
            emailAddress              = root@localhost
        X509v3 extensions:
            X509v3 Subject Key Identifier:
                4F:EA:92:62:A6:FF:9A:50:5B:7F:56:D7:95:BF:EC:85:A8:1F:1C:BD
            X509v3 Authority Key Identifier:
                keyid:3B:0A:78:EE:FD:01:31:08:11:63:C5:2A:43:EF:95:AD:98:38:A2:FB

            X509v3 Basic Constraints:
                CA:TRUE, pathlen:1
            X509v3 Key Usage:
                Certificate Sign, CRL Sign
            X509v3 CRL Distribution Points:

                Full Name:
                  URI:http://ecs-matrix-ca/level1-ca.crl

Certificate is to be certified until Jun  7 06:59:16 2025 GMT (365 days)
Sign the certificate? [y/n]:y


1 out of 1 certificate requests certified, commit? [y/n]y
Write out database with 1 new entries
Data Base Updated
```

## Level-2 CA
Note: It will be signed by `Level-1 CA`  
### Config
```bash
$ mkdir -p CA-Level2

$ cat <<EOF> CA-Level2/CA-Level2.cnf
[ req ]
distinguished_name      = req_distinguished_name
req_extensions          = leve2_ca # The extensions to add to a certificate request

[ req_distinguished_name ]
countryName                     = Country Name (2 letter code)
stateOrProvinceName             = State or Province Name (full name)
localityName                    = Locality Name (eg, city)
organizationName                = Organization Name (eg, company)
organizationalUnitName          = Organizational Unit Name (eg, section)
commonName                      = Common Name (eg, your name or your server\'s hostname)
emailAddress                    = Email Address

[ leve2_ca ]
subjectKeyIdentifier            = hash
basicConstraints                = CA:true, pathlen:0
keyUsage                        = cRLSign, keyCertSign
crlDistributionPoints           = @crl_section

[ crl_section ]
URI.1                           = http://ecs-matrix-ca/level2-ca.crl
EOF
```

### Generate Level-2 CA Private Key
```bash
$ openssl genrsa -out CA-Level2/CA-Level2.key -des3 2048
```

### Generate Level-2 CA Cert Sign Request
```bash
$ openssl req -new -out CA-Level2/CA-Level2.csr -key CA-Level2/CA-Level2.key -config CA-Level2/CA-Level2.cnf -subj '/C=CN/ST=Beijing/L=Beijing/O=Example Ltd/OU=CA-Level2/CN=CA-Level2/emailAddress=root@localhost' -extensions leve2_ca
```

### Sign Level-2 CA Public Cert
#### Config
```bash
$ mkdir -p CA-Level1/{certs,crl,newcerts}

$ touch CA-Level1/index.txt

$ echo 01 > CA-Level1/serial

# Config for Level-2 CA Cert Sign
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
crl             = \$dir/CA-Level1.crl   # The current CRL
private_key     = \$dir/CA-Level1.key   # The private key
RANDFILE        = \$dir/.rand           # private random number file
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
x509_extensions         = level2_ca # The extentions to add to the self signed cert
string_mask             = utf8only

[ req_distinguished_name ]
countryName                     = Country Name (2 letter code)
stateOrProvinceName             = State or Province Name (full name)
localityName                    = Locality Name (eg, city)
organizationName                = Organization Name (eg, company)
organizationalUnitName          = Organizational Unit Name (eg, section)
commonName                      = Common Name (eg, your name or your server\'s hostname)
emailAddress                    = Email Address

[ req_attributes ]
challengePassword               = A challenge password
challengePassword_min           = 4
challengePassword_max           = 20
unstructuredName                = An optional company name

[ level2_ca ]
subjectKeyIdentifier            = hash
authorityKeyIdentifier          = keyid:always,issuer
basicConstraints                = CA:true, pathlen:0
crlDistributionPoints           = @crl_section

[ crl_section ]
URI.1                           = http://ecs-matrix-ca/level1-ca.crl
EOF  
```

#### Cert Sign
```bash
$ $ openssl ca -in CA-Level2/CA-Level2.csr -out CA-Level2/CA-Level2.crt -config CA-Level1/CA-Level1-Sign.cnf -extensions level2_ca
Using configuration from CA-Level1/CA-Level1-Sign.cnf
Enter pass phrase for /home/jun_zou/CA-Level1/CA-Level1.key:
Check that the request matches the signature
Signature ok
Certificate Details:
        Serial Number: 1 (0x1)
        Validity
            Not Before: Jun  7 07:22:11 2024 GMT
            Not After : Jun  7 07:22:11 2025 GMT
        Subject:
            countryName               = CN
            stateOrProvinceName       = Beijing
            organizationName          = Example Ltd
            organizationalUnitName    = CA-Level2
            commonName                = CA-Level2
            emailAddress              = root@localhost
        X509v3 extensions:
            X509v3 Subject Key Identifier:
                CC:BC:89:CC:B8:4D:3F:E8:AE:73:03:14:F1:34:31:03:E8:C1:52:31
            X509v3 Authority Key Identifier:
                keyid:4F:EA:92:62:A6:FF:9A:50:5B:7F:56:D7:95:BF:EC:85:A8:1F:1C:BD

            X509v3 Basic Constraints:
                CA:TRUE, pathlen:0
            X509v3 CRL Distribution Points:

                Full Name:
                  URI:http://ecs-matrix-ca/level2-ca.crl

Certificate is to be certified until Jun  7 07:22:11 2025 GMT (365 days)
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
subjectAltName                  = @alt_names_ecs_matrix_https_server
crlDistributionPoints           = @crl_section

[alt_names_ecs_matrix_https_server]
DNS.1                           = ecs-matrix-https-server
IP.1                            = 172.16.1.157
IP.2                            = 127.0.0.1

[ crl_section ]
URI.1                           = http://ecs-matrix-ca/level2-ca.crl
EOF
```

### Generate Server Private Key
```bash
$ openssl genrsa -out ecs-matrix-https-server/ecs-matrix-https-server.key 2048
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
crl             = \$dir/CA-Level2.crl   # The current CRL
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
stateOrProvinceName             = State or Province Name (full name)
localityName                    = Locality Name (eg, city)
organizationName                = Organization Name (eg, company)
organizationalUnitName          = Organizational Unit Name (eg, section)
commonName                      = Common Name (eg, your name or your server\'s hostname)
emailAddress                    = Email Address

[ req_attributes ]
challengePassword               = A challenge password
challengePassword_min           = 4
challengePassword_max           = 20
unstructuredName                = An optional company name

[ v3_req ]
basicConstraints                = CA:FALSE
keyUsage                        = nonRepudiation, digitalSignature, keyEncipherment, keyAgreement
subjectAltName                  = @alt_names_ecs_matrix_https_server
crlDistributionPoints           = @crl_section

[alt_names_ecs_matrix_https_server]
DNS.1                           = ecs-matrix-https-server
IP.1                            = 172.16.1.157
IP.2                            = 127.0.0.1

[ crl_section ]
URI.1                           = http://ecs-matrix-ca/level2-ca.crl
EOF
```

#### Sign Cert
```bash
$ openssl ca -in ecs-matrix-https-server/ecs-matrix-https-server.csr -out ecs-matrix-https-server/ecs-matrix-https-server.crt -config CA-Level2/CA-Level2-Sign.cnf
Using configuration from CA-Level2/CA-Level2-Sign.cnf
Enter pass phrase for /home/jun_zou/CA-Level2/CA-Level2.key:
Check that the request matches the signature
Signature ok
Certificate Details:
        Serial Number: 2 (0x2)
        Validity
            Not Before: Jun  7 07:48:13 2024 GMT
            Not After : Jun  7 07:48:13 2025 GMT
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
            X509v3 Key Usage:
                Digital Signature, Non Repudiation, Key Encipherment, Key Agreement
            X509v3 Subject Alternative Name:
                DNS:ecs-matrix-https-server, IP Address:172.16.1.157, IP Address:127.0.0.1
Certificate is to be certified until Jun  7 07:48:13 2025 GMT (365 days)
Sign the certificate? [y/n]:y


1 out of 1 certificate requests certified, commit? [y/n]y
Write out database with 1 new entries
Data Base Updated
```

## Revoke a Cert
### Generate CRL file
```bash
$ echo 01 | sudo tee /etc/pki/CA/crlnumber

$ sudo openssl ca -gencrl -out /etc/pki/CA/crl.pem

$ echo 01 > CA-Level1/crlnumber

$ openssl ca -gencrl -config CA-Level1/CA-Level1-Sign.cnf -out CA-Level1/CA-Level1.crl

$ echo 01 > CA-Level2/crlnumber

$ openssl ca -gencrl -config CA-Level2/CA-Level2-Sign.cnf -out CA-Level2/CA-Level2.crl
```

### Revoke Cert
```bash
$ openssl ca -revoke /etc/pki/CA/newcerts/02.pem
Using configuration from /etc/pki/tls/openssl.cnf
Enter pass phrase for /etc/pki/CA/private/my-ca.key:
Revoking Certificate 02.
Data Base Updated

$ openssl ca -gencrl -config CA-Level2/CA-Level2-Sign.cnf -out CA-Level2/CA-Level2.crl
```
NOTE: Everytime when cert was revoking, `CRL` file need to be manually updated as it can't be automatically updated.  

### Publish CRL Info
NOTE: Format for CRL need to be converted from `PEM` to `DER` as speficied in RFC5280 while using with `HTTP` or `FTP`  
[When the HTTP or FTP URI scheme is used, the URI MUST point to a single DER encoded CRL as specified in RFC2585](https://www.rfc-editor.org/rfc/rfc5280#section-4.2.1.13) 
```bash
$ sudo openssl crl -in CA-Level2/CA-Level2.crl -outform DER -out /var/www/html/level2-ca.crl
```

### Verify
NOTE: `openssl s_client` will not download `CRL` based on url provided in certs. For crl verification, it should be done with `openssl verify` 
```bash
$ sed -n -E '/BEGIN/,/END/p' CA-Level1.crt CA-Level2.crt > intermediate-ca.crt

$ openssl verify  -CAfile /etc/pki/CA/root-ca.crt -untrusted intermediate-ca.crt -crl_check -crl_download ecs-matrix-https-server.crt
ecs-matrix-https-server.crt: C = CN, ST = Beijing, O = Example Ltd, OU = ecs-matrix-https-server, CN = ecs-matrix-https-server, emailAddress = root@localhost
error 23 at 0 depth lookup:certificate revoked
```
`-crl_download` will download CRL file automatically.  

OR download it manually and verify with `-CRLfile` option
```bash
$ openssl x509 -in ecs-matrix-https-server.crt -noout -text  | grep -A3 'CRL'
            X509v3 CRL Distribution Points:

                Full Name:
                  URI:http://ecs-matrix-ca/level2-ca.crl

$ curl -o level2-ca.crl 'http://ecs-matrix-ca/level2-ca.crl'

$ openssl crl -in level2-ca.crl -inform DER -out level2-ca-crl.pem -outform PEM

$ openssl verify  -CAfile /etc/pki/CA/root-ca.crt -untrusted intermediate-ca.crt -crl_check -CRLfile level2-ca-crl.pem ecs-matrix-https-server.crt
ecs-matrix-https-server.crt: C = CN, ST = Beijing, O = Example Ltd, OU = ecs-matrix-https-server, CN = ecs-matrix-https-server, emailAddress = root@localhost
error 23 at 0 depth lookup:certificate revoked
```

## HTTPS Verification
### Apache HTTP
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

Verify 
```bash
$ curl --cacert CA-Level2/CA-Level2.crt https://ecs-matrix-https-server
ecs-matrix-https-server

$ curl --cacert /etc/pki/CA/root-ca.crt https://ecs-matrix-https-server 2>/dev/null

$ echo $?
60

$ echo | openssl s_client -connect ecs-matrix-https-server:443 2>/dev/null | grep 'Verify return code'
    Verify return code: 20 (unable to get local issuer certificate)
```

```bash
$ tailf /etc/httpd/logs/ssl_request_log
...
[06/Jun/2024:07:42:00 +0000] 172.16.1.245 TLSv1.2 ECDHE-RSA-AES256-GCM-SHA384 "GET / HTTP/1.1" 24
...
```

### Alternative HTTP Config to include intermediate CA
include intermediate certs in config
```bash
$ sed -n -E '/BEGIN/,/END/p' CA-Level1/CA-Level1.crt CA-Level2/CA-Level2.crt > intermediate-ca.crt
```

```bash
$ sudo sed -i.bak-cert-chain '/SSLCertificateKeyFile/a\    SSLCertificateChainFile /etc/httpd/certs/intermediate-ca.crt' /etc/httpd/conf.d/ssl.conf

$ diff -Nru /etc/httpd/conf.d/ssl.conf /etc/httpd/conf.d/ssl.conf.bak-cert-chain
--- /etc/httpd/conf.d/ssl.conf  2024-06-06 07:48:16.738244189 +0000
+++ /etc/httpd/conf.d/ssl.conf.bak-cert-chain   2024-06-06 06:40:15.764740916 +0000
@@ -31,5 +31,4 @@

     SSLCertificateFile /etc/httpd/certs/ecs-matrix-https-server.crt
     SSLCertificateKeyFile /etc/httpd/certs/ecs-matrix-https-server.key
-    SSLCertificateChainFile /etc/httpd/certs/intermediate-ca.crt
 </VirtualHost>

$ sudo systemctl restart httpd
```

Verify
```bash
$ curl --cacert /etc/pki/CA/root-ca.crt https://ecs-matrix-https-server
ecs-matrix-https-server
```

### Nginx
```bash
$ sudo yum install -y nginx

$ sed -n -E '/BEGIN/,/END/p' /etc/httpd/certs/ecs-matrix-https-server.crt /etc/httpd/certs/CA-Level1.crt /etc/httpd/certs/CA-Level2.crt > /etc/httpd/certs/all-certs.crt

$ cat <<EOF | sudo tee /etc/nginx/conf.d/ssl.conf
server {
    listen              443 ssl http2;
    server_name         ecs-matrix-https-server;
    root                /usr/share/nginx/html;
    ssl_certificate     /etc/httpd/certs/all-certs.crt;
    ssl_certificate_key /etc/httpd/certs/ecs-matrix-https-server.key;
    ssl_session_timeout 10m;
    ssl_ciphers         HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    error_page 404 /404.html;
        location = /40x.html {
    }
    error_page 500 502 503 504 /50x.html;
        location = /50x.html {
    }
}
EOF

$ echo "Welcome to Nginx on $(hostname -s)" | sudo tee /usr/share/nginx/html/index.html

$ sudo systemctl restart nginx
```

Verify
```bash
$ curl --cacert /etc/pki/CA/root-ca.crt https://ecs-matrix-https-server
Welcome to Nginx on ecs-matrix-https-server
```

## CMD Memo
### Check Private Key File
```bash
$ openssl rsa -in <Private Key File> -noout -text
```

### Check Cert Request File
```bash
$ openssl req -in <Cert Request File> -noout -text
```

### Check Public Cert File
```bash
$ openssl x509 -in <Cert File> -noout -text
```

### Check subject info for a Public Cert File
```bash
$ openssl x509 -in <Cert File> -noout -subject
```

### Check issuer info for a Public Cert File
```bash
$ openssl x509 -in <Cert File> -noout -issuer
```

### Verify Cert with `openssl`
```bash
$ echo | openssl s_client -connect ecs-matrix-https-server:443 2>/dev/null | grep 'Verify return code'
```
If `return code` is not `0`, it means error occurred. 

### Script to download Certs Chain for a site
```bash
$ cat <<EOF> cert.awk
/\s*[0-9] s:/ {
    cert_cn = gensub(/.*CN ?=([^\/]*).*/, "\\\\1", "g")
    # remove leading [*. ]
    gsub(/^[*. ]*/, "", cert_cn)
    # replace any of [*. -] with _
    gsub(/[*. -]/, "_", cert_cn)
    # replace multi continous _ with single _
    gsub(/_{2,}/, "_", cert_cn)
    # convert uppercase to lower
    cert_file = tolower(cert_cn)".crt"
}
/-----BEGIN CERTIFICATE-----/ {
    f=1
    print "Copying Cert to "cert_file
}
f {
    print > cert_file
}
/-----END CERTIFICATE-----/ {
    f=0
}
EOF

$ host='ecs-matrix-https-server'

$ echo | openssl s_client -showcerts -connect "${host}:443" 2>&1 | awk -f cert.awk
Copying Cert to ecs_matrix_https_server.crt
Copying Cert to ca_level1.crt
Copying Cert to ca_level2.crt
```

{% include links.html %}