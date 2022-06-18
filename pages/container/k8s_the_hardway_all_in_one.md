---
title: Kubernetes All-in-One Deployment in the Hard Way 
tags: [contianer]
keywords: kubernetes, k8s
last_updated: Jun 18, 2022
summary: "All in one deployment for Kubernetes cluster in the hard Way"
sidebar: mydoc_sidebar
permalink: k8s_the_hardway_all_in_one.html
folder: Container
---

# Kubernetes All-in-One Deployment in the Hard Way
=====

## Env
| Item | Explanation |  Value in config | config file |
| :------ | :------ | :------ | :------ |
| cluster-name | | ecs-matrix-k8s-cluster-all-in-one | admin.kubeconfig, kubelet.kubeconfig, kube-proxy.kubeconfig |
| service-cluster-ip-range | A CIDR IP range from which to assign service cluster IPs | 10.32.0.0/24 | kube-apiserver.service |
| cluster-cidr | CIDR Range for Pods in cluster | 10.64.1.0/24 | kube-controller-manager.service, kube-proxy-config.yaml |
| podCIDR | | 10.64.1.0/24 | 10-bridge.conf,  kubelet-config.yaml |

## CA
### Config
```bash
# cat <<EOF > /etc/pki/tls/openssl.cnf
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
new_certs_dir   = \$dir/newcerts                # default place for new certs.
certificate     = \$dir/ca.crt          # The CA certificate
serial          = \$dir/serial          # The current serial number
crlnumber       = \$dir/crlnumber       # the current crl number
                                        # must be commented out to leave a V1 CRL
crl             = \$dir/ca.crl          # The current CRL
private_key     = \$dir/private/ca.key   # The private key
RANDFILE        = \$dir/private/.rand   # private random number file
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

[ policy_anything ]
countryName             = optional
stateOrProvinceName     = optional
localityName            = optional
organizationName        = optional
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional

[ req ]
default_bits            = 2048
default_md              = sha256
default_keyfile         = privkey.pem
distinguished_name      = req_distinguished_name
attributes              = req_attributes
x509_extensions = v3_ca # The extentions to add to the self signed cert

string_mask = utf8only

[ req_distinguished_name ]
countryName                     = Country Name (2 letter code)
countryName_default             = XX
countryName_min                 = 2
countryName_max                 = 2
stateOrProvinceName             = State or Province Name (full name)
localityName                    = Locality Name (eg, city)
localityName_default            = Default City
0.organizationName              = Organization Name (eg, company)
0.organizationName_default      = Default Company Ltd
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

[ usr_cert ]
basicConstraints=CA:FALSE
nsComment                       = "OpenSSL Generated Certificate"
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid,issuer

[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment

[ v3_ca ]
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid:always,issuer
basicConstraints = CA:true

[ crl_ext ]
authorityKeyIdentifier=keyid:always

[ proxy_cert_ext ]
basicConstraints=CA:FALSE
nsComment                       = "OpenSSL Generated Certificate"
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid,issuer
proxyCertInfo=critical,language:id-ppl-anyLanguage,pathlen:3,policy:foo

[ tsa ]
default_tsa = tsa_config1       # the default TSA section

[ tsa_config1 ]
dir             = ./demoCA              # TSA root directory
serial          = \$dir/tsaserial       # The current serial number (mandatory)
crypto_device   = builtin               # OpenSSL engine to use for signing
signer_cert     = \$dir/tsacert.pem     # The TSA signing certificate
                                        # (optional)
certs           = \$dir/cacert.pem      # Certificate chain to include in reply
                                        # (optional)
signer_key      = \$dir/private/tsakey.pem # The TSA private key (optional)
default_policy  = tsa_policy1           # Policy if request did not specify it
                                        # (optional)
other_policies  = tsa_policy2, tsa_policy3      # acceptable policies (optional)
digests         = sha1, sha256, sha384, sha512  # Acceptable message digests (mandatory)
accuracy        = secs:1, millisecs:500, microsecs:100  # (optional)
clock_precision_digits  = 0     # number of digits after dot. (optional)
ordering                = yes   # Is ordering defined for timestamps?
                                # (optional, default: no)
tsa_name                = yes   # Must the TSA name be included in the reply?
                                # (optional, default: no)
ess_cert_id_chain       = no    # Must the ESS cert id chain be included?
                                # (optional, default: no)
EOF        
```

create a file to indicate the next certificate serial number to be issued
```bash
# echo 01 > /etc/pki/CA/serial
```

Create an empty certificate index
```bash
# touch /etc/pki/CA/index.txt
```

### Generate CA Private key
```bash
# (umask 077; openssl genrsa -out /etc/pki/CA/private/ca.key -des3 2048)
```
output
```
Generating RSA private key, 2048 bit long modulus
...................................+++
......................+++
e is 65537 (0x10001)
Enter pass phrase for /etc/pki/CA/private/ca.key:
Verifying - Enter pass phrase for /etc/pki/CA/private/ca.key:
```

### Generate CA public Cert
```bash
# openssl req -new -x509 -key /etc/pki/CA/private/my-ca.key -days 365 > /etc/pki/CA/my-ca.crt
```
output
```bash
Enter pass phrase for /etc/pki/CA/private/my-ca.key:
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [US]: CN
State or Province Name (full name) [New York]: BJ
Locality Name (eg, city) [New York]: Beijing
Organization Name (eg, company) [Example]: Matrix
Organizational Unit Name (eg, section) []: Matrix
Common Name (eg, your name or your server's hostname) []:ecs-matrix-k8s-cluster-2
Email Address []:root@ecs-matrix-k8s-cluster-2
```

## kube-apiserver
### Cert
##### config
The Kubernetes API server is automatically assigned the `kubernetes` internal dns name, which will be linked to the first IP address (`10.32.0.1`) from the address range of `service-cluster-ip-range`(`10.32.0.0/24`) reserved for internal cluster services
```bash
# cat <<EOF > apiserver.cnf
[ ca ]
default_ca      = CA_default            # The default ca section

[ CA_default ]
dir             = /etc/pki/CA           # Where everything is kept
certs           = \$dir/certs            # Where the issued certs are kept
crl_dir         = \$dir/crl              # Where the issued crl are kept
database        = \$dir/index.txt        # database index file.
new_certs_dir   = \$dir/newcerts         # default place for new certs.

certificate     = \$dir/ca.crt           # The CA certificate
serial          = \$dir/serial           # The current serial number
crlnumber       = \$dir/crlnumber        # the current crl number
                                        # must be commented out to leave a V1 CRL
crl             = \$dir/ca.crl           # The current CRL
private_key     = \$dir/private/ca.key   # The private key
RANDFILE        = \$dir/private/.rand    # private random number file

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
DNS.1 = kubernetes
DNS.2 = kubernetes.default
DNS.3 = kubernetes.default.svc
DNS.4 = kubernetes.default.svc.cluster
DNS.5 = kubernetes.svc.cluster.local
DNS.6 = ecs-matrix-k8s-cluster-2
IP.1 = 127.0.0.1
IP.2 = 10.32.0.1
IP.3 = 172.16.1.180
EOF
```

##### Private Key
```bash
# openssl genrsa -out apiserver.key 2048
```

##### Cert Request 
```bash
# openssl req -new -out apiserver.csr -key apiserver.key -config apiserver.cnf

# openssl req -in apiserver.csr -noout -text
Certificate Request:
    Data:
        Version: 0 (0x0)
        Subject: C=CN, ST=BJ, L=Beijing, O=Matrix, OU=Matrix, CN=kubernetes/emailAddress=root@ecs_matrix_k8s_cluster_2
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (2048 bit)
                Modulus:
                    00:f3:48:fa:3f:01:e2:89:a6:72:e1:df:5b:bd:33:
                    54:65:b0:75:5b:1d:24:08:30:29:52:2f:47:07:b3:
                    47:47:80:bf:22:6c:1f:80:75:17:7f:2f:ff:81:ad:
                    2b:c5:28:2d:4b:d9:dd:e7:94:8a:06:4e:94:c5:0b:
                    00:5a:13:07:61:58:9d:4d:51:c8:17:ae:d3:f7:bd:
                    6d:32:09:50:04:85:7f:f4:4e:21:6f:81:20:42:24:
                    ac:89:96:4f:30:6c:65:7b:92:dd:7e:0e:55:06:df:
                    41:6c:b7:a5:e3:e2:5c:4f:62:cf:24:47:1d:fe:65:
                    1e:6f:90:69:38:8a:30:b7:7a:80:19:7c:3f:cd:76:
                    b8:f8:57:90:4e:ce:e6:8b:fd:d3:07:fd:74:d6:96:
                    5d:21:ad:e6:38:6d:3b:d0:11:45:c4:25:62:97:fb:
                    a4:28:21:15:da:05:bd:36:f8:0a:e6:1a:04:d5:bb:
                    a0:d4:62:36:49:17:fd:ca:71:57:26:c0:73:6e:49:
                    94:7d:5a:27:17:2f:2b:ca:e5:df:13:e1:77:c8:9a:
                    7e:4b:cd:ec:1a:cb:51:4a:f0:c5:9b:37:97:10:e2:
                    cd:ea:bf:4f:11:a9:75:8e:87:6a:da:c5:e6:d2:c7:
                    27:3c:33:e4:86:21:da:1b:14:09:0c:48:67:1a:66:
                    f6:13
                Exponent: 65537 (0x10001)
        Attributes:
        Requested Extensions:
            X509v3 Basic Constraints:
                CA:FALSE
            X509v3 Key Usage:
                Digital Signature, Non Repudiation, Key Encipherment, Key Agreement

    Signature Algorithm: sha256WithRSAEncryption
         ac:86:32:5c:05:fe:be:39:ca:55:7d:5a:74:7a:cb:df:6e:a4:
         b1:a5:f7:c6:12:c9:7e:03:e9:98:a9:79:7b:ee:a6:fc:41:e8:
         41:09:2e:c2:71:73:5a:26:71:9c:66:36:07:8d:db:52:89:5a:
         8a:aa:84:3f:a0:f2:44:87:48:ca:32:d3:5e:6f:0a:7b:61:fd:
         51:dc:b6:7f:e8:0e:3c:6c:75:4e:2b:06:0d:bd:9c:e4:15:ac:
         0b:c4:df:7f:d1:6e:12:48:2f:da:ff:0d:db:7c:f2:ae:77:05:
         99:0b:ae:47:be:51:20:56:18:72:73:fb:53:e3:06:72:50:47:
         57:1b:23:7a:bb:d5:50:80:45:09:5d:3d:97:5b:3b:29:ae:22:
         94:e3:33:fd:95:58:2f:1d:2a:59:d8:96:e7:bb:45:b3:6c:1c:
         eb:7a:96:ad:f9:5e:3f:c8:74:12:9c:7b:eb:6a:7d:84:e6:42:
         f0:91:3f:ce:24:da:64:e6:3a:c0:3c:21:b4:09:cb:4c:82:6a:
         de:26:9e:5a:e7:6c:19:24:36:fe:43:fa:2c:13:4f:5e:1b:86:
         a3:c5:97:ff:fe:88:45:e2:4b:ca:b3:4a:20:25:f7:b7:03:dd:
         f0:5e:19:50:10:43:95:39:35:31:81:7c:83:10:3d:9a:c5:1e:
         ff:35:2d:dc
```

##### Public Cert
```bash
# openssl ca -in apiserver.csr -out apiserver.crt -config apiserver.cnf
```

## etcd 
### Tools download
```bash
# wget  https://github.com/etcd-io/etcd/releases/download/v3.4.15/etcd-v3.4.15-linux-amd64.tar.gz

#  mkdir etcd

#  tar xvf etcd-v3.4.15-linux-amd64.tar.gz -C etcd/

#  cp -v etcd/etcd-v3.4.15-linux-amd64/etcd* /usr/local/bin/
```

### Config
```bash
# mkdir -p /etc/etcd

# mkdir -p /var/lib/etcd

# cp /etc/pki/CA/ca.crt /etc/etcd/

# cp ~/certs/apiserver/apiserver.crt /etc/etcd/

# cp ~/certs/apiserver/apiserver.key /etc/etcd/

# HOSTNAME=$(hostname -s)

# LOCAL_IP=$(ifconfig eth0 | awk '/inet /{print $2}')

# cat <<EOF > /etc/systemd/system/etcd.service
[Unit]
Description=etcd
Documentation=https://github.com/coreos

[Service]
Type=notify
ExecStart=/usr/local/bin/etcd \\
  --name ${HOSTNAME} \\
  --cert-file=/etc/etcd/apiserver.crt \\
  --key-file=/etc/etcd/apiserver.key \\
  --peer-cert-file=/etc/etcd/apiserver.crt \\
  --peer-key-file=/etc/etcd/apiserver.key \\
  --trusted-ca-file=/etc/etcd/ca.crt \\
  --peer-trusted-ca-file=/etc/etcd/ca.crt \\
  --peer-client-cert-auth \\
  --client-cert-auth \\
  --initial-advertise-peer-urls https://${LOCAL_IP}:2380 \\
  --listen-peer-urls https://${LOCAL_IP}:2380 \\
  --listen-client-urls https://${LOCAL_IP}:2379,https://127.0.0.1:2379 \\
  --advertise-client-urls https://${LOCAL_IP}:2379 \\
  --initial-cluster ${HOSTNAME}=https://${LOCAL_IP}:2380 \\
  --initial-cluster-state new \\
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# systemctl daemon-reload

# systemctl enable --now etcd.service
```

### Verify
```bash
# ETCDCTL_API=3 /usr/local/bin/etcdctl member list  --endpoints=https://127.0.0.1:2379   --cacert=/etc/etcd/ca.crt --cert=/etc/etcd/apiserver.crt   --key=/etc/etcd/apiserver.key
7a4c7b48f4bff473, started, ecs-matrix-k8s-cluster-2, https://172.16.1.180:2380, https://172.16.1.180:2379, false
```

## kube-apiserver
### Config
```bash
# mkdir /var/lib/kubernetes/

# ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)

# cat <<EOF >encryption-config.yaml 
kind: EncryptionConfig
apiVersion: v1
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
         keys:
           - name: key1
             secret: ${ENCRYPTION_KEY}
      - identity: {}
EOF

# cp encryption-config.yaml /var/lib/kubernetes/

# cp /etc/etcd/ca.crt /var/lib/kubernetes/

# cp /etc/etcd/apiserver.crt /var/lib/kubernetes/

# cp /etc/etcd/apiserver.key /var/lib/kubernetes/

# cat <<EOF > /etc/systemd/system/kube-apiserver.service
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-apiserver \
  --advertise-address=${LOCAL_IP} \
  --allow-privileged=true \
  --apiserver-count=3 \
  --audit-log-maxage=30 \
  --audit-log-maxbackup=3 \
  --audit-log-maxsize=100 \
  --audit-log-path=/var/log/audit.log \
  --authorization-mode=Node,RBAC \
  --bind-address=0.0.0.0 \
  --client-ca-file=/var/lib/kubernetes/ca.crt \
  --enable-admission-plugins=NamespaceLifecycle,NodeRestriction,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota \
  --etcd-cafile=/var/lib/kubernetes/ca.crt \
  --etcd-certfile=/var/lib/kubernetes/apiserver.crt \
  --etcd-keyfile=/var/lib/kubernetes/apiserver.key \
  --etcd-servers=https://${LOCAL_IP}:2379 \
  --event-ttl=1h \
  --encryption-provider-config=/var/lib/kubernetes/encryption-config.yaml \
  --kubelet-certificate-authority=/var/lib/kubernetes/ca.crt \
  --kubelet-client-certificate=/var/lib/kubernetes/apiserver.crt \
  --kubelet-client-key=/var/lib/kubernetes/apiserver.key \
  --runtime-config=api/all=true \
  --service-account-issuer=https://${LOCAL_IP}:6443 \
  --service-account-key-file=/var/lib/kubernetes/apiserver.crt \
  --service-account-signing-key-file=/var/lib/kubernetes/apiserver.key \
  --service-cluster-ip-range=10.32.0.0/24 \
  --service-node-port-range=30000-32767 \
  --tls-cert-file=/var/lib/kubernetes/apiserver.crt \
  --tls-private-key-file=/var/lib/kubernetes/apiserver.key \
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target

# systemctl daemon-reload

# systemctl enable --now kube-apiserver.service
```

### Verify
```bash
# curl --cacert /etc/etcd/ca.crt -i https://127.0.0.1:6443/healthz
HTTP/1.1 200 OK
Cache-Control: no-cache, private
Content-Type: text/plain; charset=utf-8
X-Content-Type-Options: nosniff
X-Kubernetes-Pf-Flowschema-Uid: 433f7709-03d2-4f5b-bbd6-cdc4258fa304
X-Kubernetes-Pf-Prioritylevel-Uid: 34e4c49c-2184-408b-9af2-80013b24bf49
Date: Sun, 12 Jun 2022 08:04:23 GMT
Content-Length: 2

# curl --cacert /etc/etcd/ca.crt -i https://127.0.0.1:6443/version
HTTP/1.1 200 OK
Cache-Control: no-cache, private
Content-Type: application/json
X-Kubernetes-Pf-Flowschema-Uid: 433f7709-03d2-4f5b-bbd6-cdc4258fa304
X-Kubernetes-Pf-Prioritylevel-Uid: 34e4c49c-2184-408b-9af2-80013b24bf49
Date: Sun, 12 Jun 2022 08:05:31 GMT
Content-Length: 263

{
  "major": "1",
  "minor": "21",
  "gitVersion": "v1.21.0",
  "gitCommit": "cb303e613a121a29364f75cc67d3d580833a7479",
  "gitTreeState": "clean",
  "buildDate": "2021-04-08T16:25:06Z",
  "goVersion": "go1.16.1",
  "compiler": "gc",
  "platform": "linux/amd64"
}
```

## admin
### Tools download
```bash
# wget https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kubectl

# cp kubectl /usr/local/bin/
```

### Certs
Notes: `O`(Organization) in certs must be `system:masters`

##### Config
```bash
# cat <<EOF >admin.cnf
[ ca ]
default_ca      = CA_default            # The default ca section

[ CA_default ]

dir             = /etc/pki/CA           # Where everything is kept
certs           = \$dir/certs            # Where the issued certs are kept
crl_dir         = \$dir/crl              # Where the issued crl are kept
database        = \$dir/index.txt        # database index file.

new_certs_dir   = \$dir/newcerts         # default place for new certs.

certificate     = \$dir/ca.crt           # The CA certificate
serial          = \$dir/serial           # The current serial number
crlnumber       = \$dir/crlnumber        # the current crl number
                                        # must be commented out to leave a V1 CRL
crl             = \$dir/ca.crl           # The current CRL
private_key     = \$dir/private/ca.key   # The private key
RANDFILE        = \$dir/private/.rand    # private random number file

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
organizationName        = optional
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional

[ usr_cert ]

basicConstraints=CA:FALSE
nsComment                       = "OpenSSL Generated Certificate"
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid,issuer

[ req ]
distinguished_name      = req_distinguished_name

[ req_distinguished_name ]
countryName                     = Country Name (2 letter code)
stateOrProvinceName             = State or Province Name (full name)
localityName                    = Locality Name (eg, city)
organizationName                = Organization Name (eg, company)
organizationalUnitName          = Organizational Unit Name (eg, section)
commonName                      = Common Name (eg, your name or your server\'s hostname)
emailAddress                    = Email Address
EOF
```

##### Privete key
```bash
# openssl genrsa -out admin.key 2048
```

##### Cert Request
```bash
# openssl req -new -key admin.key -out admin.csr -config admin.cnf
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) []:CN
State or Province Name (full name) []:BJ
Locality Name (eg, city) []:Beijing
Organization Name (eg, company) []:system:masters
Organizational Unit Name (eg, section) []:Matrix
Common Name (eg, your name or your server's hostname) []:ecs-matrix-k8s-cluster-2
Email Address []:root@ecs-matrix-k8s-cluster-2
```

##### Sign Cert
```bash
# openssl ca -in admin.csr -out admin.crt -config admin.cnf
Using configuration from admin.cnf
Enter pass phrase for /etc/pki/CA/private/ca.key:
Check that the request matches the signature
Signature ok
Certificate Details:
        Serial Number: 2 (0x2)
        Validity
            Not Before: Jun 12 11:17:52 2022 GMT
            Not After : Jun 12 11:17:52 2023 GMT
        Subject:
            countryName               = CN
            stateOrProvinceName       = BJ
            organizationName          = system:masters
            organizationalUnitName    = Matrix
            commonName                = ecs-matrix-k8s-cluster-2
            emailAddress              = root@ecs-matrix-k8s-cluster-2
        X509v3 extensions:
            X509v3 Basic Constraints:
                CA:FALSE
            Netscape Comment:
                OpenSSL Generated Certificate
            X509v3 Subject Key Identifier:
                AA:53:17:2F:7A:AF:17:C8:D5:B9:90:8F:E4:0F:DE:51:8B:3A:E0:65
            X509v3 Authority Key Identifier:
                keyid:EC:90:22:63:D4:73:8D:8E:DC:59:B3:AA:76:18:70:00:A7:37:6D:9D

Certificate is to be certified until Jun 12 11:17:52 2023 GMT (365 days)
Sign the certificate? [y/n]:y


1 out of 1 certificate requests certified, commit? [y/n]y
Write out database with 1 new entries
Data Base Updated
```

### Config
```bash
# kubectl config set-cluster ecs-matrix-k8s-cluster-all-in-one \
  --certificate-authority=/etc/etcd/ca.crt \
  --embed-certs=true \
  --server=https://127.0.0.1:6443 \
  --kubeconfig=admin.kubeconfig

# kubectl config set-cluster ecs-matrix-k8s-cluster-all-in-one \
  --certificate-authority=/etc/etcd/ca.crt \
  --embed-certs=true \
  --server=https://127.0.0.1:6443 \
  --kubeconfig=admin.kubeconfig

# kubectl config set-credentials admin \
  --client-certificate=/root/certs/admin/admin.crt \
  --client-key=/root/certs/admin/admin.key \
  --embed-certs=true \
  --kubeconfig=admin.kubeconfig

# kubectl config set-context default \
  --cluster=ecs-matrix-k8s-cluster-all-in-one \
  --user=admin \
  --kubeconfig=admin.kubeconfig

# kubectl config use-context default --kubeconfig=admin.kubeconfig

# mkdir ~/.kube

# cp admin.kubeconfig ~/.kube/config
```

### Verify
```bash
# kubectl cluster-info
Kubernetes control plane is running at https://127.0.0.1:6443

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.

# kubectl get clusterrolebindings cluster-admin -o yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  creationTimestamp: "2022-06-11T19:49:53Z"
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  name: cluster-admin
  resourceVersion: "141"
  uid: df9a70bf-4a84-4669-8329-7e2a153159c0
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: system:masters
```

## kubelet
In order to be authorized by the Node authorizer, kubelets must use a credential that identifies them as being in the `system:nodes` group, with a username of `system:node:<nodeName>`. By default, `nodeName` is the host name as provided by `hostname`, or overridden via the kubelet option `--hostname-override`. So that, `group` should be aligned with `O`(Organization) in cert, and `username` aligned with `CN`(Common Name).  
Ref: [Kubernetes Using Node Authorization](https://kubernetes.io/docs/reference/access-authn-authz/node/)

### Tools Download
```bash
wget \
  https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.21.0/crictl-v1.21.0-linux-amd64.tar.gz \
  https://github.com/opencontainers/runc/releases/download/v1.0.0-rc93/runc.amd64 \
  https://github.com/containernetworking/plugins/releases/download/v0.9.1/cni-plugins-linux-amd64-v0.9.1.tgz \
  https://github.com/containerd/containerd/releases/download/v1.4.4/containerd-1.4.4-linux-amd64.tar.gz \
  https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kubelet
```

### Cert
##### Config
```bash
# cat <<EOF >kubelet.cnf
[ ca ]
default_ca      = CA_default            # The default ca section

[ CA_default ]

dir             = /etc/pki/CA           # Where everything is kept
certs           = \$dir/certs            # Where the issued certs are kept
crl_dir         = \$dir/crl              # Where the issued crl are kept
database        = \$dir/index.txt        # database index file.

new_certs_dir   = \$dir/newcerts         # default place for new certs.

certificate     = \$dir/ca.crt           # The CA certificate
serial          = \$dir/serial           # The current serial number
crlnumber       = \$dir/crlnumber        # the current crl number
                                        # must be commented out to leave a V1 CRL
crl             = \$dir/ca.crl           # The current CRL
private_key     = \$dir/private/ca.key   # The private key
RANDFILE        = \$dir/private/.rand    # private random number file

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
organizationName        = optional
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
DNS.1 = ecs-matrix-k8s-cluster-2
IP.1 = 127.0.0.1
IP.2 = 172.16.1.180
EOF
```

##### Private key
```bash
# openssl genrsa -out kubelet.key 2048
```

##### Cert Request
```bash
# openssl req -new -out kubelet.csr -key kubelet.key
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [XX]:CN
State or Province Name (full name) []:BJ
Locality Name (eg, city) [Default City]:Beijing
Organization Name (eg, company) [Default Company Ltd]:system:nodes
Organizational Unit Name (eg, section) []:Matrix
Common Name (eg, your name or your server's hostname) []:system:node:ecs-matrix-k8s-cluster-2
Email Address []:root@ecs-matrix-k8s-cluster-2

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:
```

##### Public Cert
```bash
# openssl ca -in kubelet.csr -out kubelet.crt -config kubelet.cnf
Using configuration from kubelet.cnf
Enter pass phrase for /etc/pki/CA/private/ca.key:
Check that the request matches the signature
Signature ok
Certificate Details:
        Serial Number: 3 (0x3)
        Validity
            Not Before: Jun 12 11:39:03 2022 GMT
            Not After : Jun 12 11:39:03 2023 GMT
        Subject:
            countryName               = CN
            stateOrProvinceName       = BJ
            organizationName          = system:nodes
            organizationalUnitName    = Matrix
            commonName                = system:node:ecs-matrix-k8s-cluster-2
            emailAddress              = root@ecs-matrix-k8s-cluster-2
        X509v3 extensions:
            X509v3 Basic Constraints:
                CA:FALSE
            Netscape Comment:
                OpenSSL Generated Certificate
            X509v3 Subject Key Identifier:
                71:80:DD:60:EE:49:82:05:68:21:9F:67:DA:5D:52:C0:FA:A1:8F:A1
            X509v3 Authority Key Identifier:
                keyid:EC:90:22:63:D4:73:8D:8E:DC:59:B3:AA:76:18:70:00:A7:37:6D:9D

Certificate is to be certified until Jun 12 11:39:03 2023 GMT (365 days)
Sign the certificate? [y/n]:y


1 out of 1 certificate requests certified, commit? [y/n]y
Write out database with 1 new entries
Data Base Updated
```

### Config
##### CNI Network
```bash
# modprobe br_netfilter

# mkdir /opt/cni/bin -p

# tar xvf cni-plugins-linux-amd64-v0.9.1.tgz -C /opt/cni/bin/
./
./macvlan
./flannel
./static
./vlan
./portmap
./host-local
./vrf
./bridge
./tuning
./firewall
./host-device
./sbr
./loopback
./dhcp
./ptp
./ipvlan
./bandwidth

# mkdir -p /etc/cni/net.d/

# POD_CIDR='10.64.1.0/24'

# cat <<EOF >/etc/cni/net.d/10-bridge.conf
{
    "cniVersion": "0.4.0",
    "name": "bridge",
    "type": "bridge",
    "bridge": "cnio0",
    "isGateway": true,
    "ipMasq": true,
    "ipam": {
        "type": "host-local",
        "ranges": [
          [{"subnet": "${POD_CIDR}"}]
        ],
        "routes": [{"dst": "0.0.0.0/0"}]
    }
}
EOF
         
# cat <<EOF >/etc/cni/net.d/99-loopback.conf
{
    "cniVersion": "0.4.0",
    "name": "lo",
    "type": "loopback"
}
EOF
```

##### containerd
```bash
# mkdir -p containerd

# tar xvf containerd-1.4.4-linux-amd64.tar.gz -C containerd
bin/
bin/containerd
bin/containerd-shim
bin/containerd-shim-runc-v2
bin/containerd-shim-runc-v1
bin/ctr

# cp -arv containerd/bin/* /bin/
‘containerd/bin/containerd’ -> ‘/bin/containerd’
‘containerd/bin/containerd-shim’ -> ‘/bin/containerd-shim’
‘containerd/bin/containerd-shim-runc-v1’ -> ‘/bin/containerd-shim-runc-v1’
‘containerd/bin/containerd-shim-runc-v2’ -> ‘/bin/containerd-shim-runc-v2’
‘containerd/bin/ctr’ -> ‘/bin/ctr’

# cp runc.amd64 /usr/local/bin/runc

# chmod 755 /usr/local/bin/runc

# mkdir -p /etc/containerd/

# cat <<EOF >/etc/containerd/config.toml
[plugins]
  [plugins.cri.containerd]
    snapshotter = "overlayfs"
    [plugins.cri.containerd.default_runtime]
      runtime_type = "io.containerd.runtime.v1.linux"
      runtime_engine = "/usr/local/bin/runc"
      runtime_root = ""
EOF

# cat <<EOF >/etc/systemd/system/containerd.service
[Unit]
Description=containerd container runtime
Documentation=https://containerd.io
After=network.target

[Service]
ExecStartPre=/sbin/modprobe overlay
ExecStart=/bin/containerd
Restart=always
RestartSec=5
Delegate=yes
KillMode=process
OOMScoreAdjust=-999
LimitNOFILE=1048576
LimitNPROC=infinity
LimitCORE=infinity

[Install]
WantedBy=multi-user.target
EOF

# systemctl daemon-reload

# systemctl enable --now containerd.service
```

##### kubelet
```bash
# kubectl config set-cluster ecs-matrix-k8s-cluster-all-in-one --certificate-authority=/etc/etcd/ca.crt --embed-certs=true --server=https://172.16.1.180:6443 --kubeconfig=kubelet.kubeconfig

# kubectl config set-credentials system:node:ecs-matrix-k8s-cluster-2 --client-certificate=/root/certs/kubelet/kubelet.crt --client-key=/root/certs/kubelet/kubelet.key --embed-certs=true --kubeconfig=kubelet.kubeconfig

# kubectl config set-context default --cluster=ecs-matrix-k8s-cluster-all-in-one --user=system:node:ecs-matrix-k8s-cluster-2 --kubeconfig=kubelet.kubeconfig

# kubectl config use-context default --kubeconfig=kubelet.kubeconfig

# mkdir -p /run/systemd/resolve

# ln -s /etc/resolv.conf /run/systemd/resolve/resolv.conf

# cat <<EOF >kubelet-config.yaml
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false
  webhook:
    enabled: true
  x509:
    clientCAFile: "/var/lib/kubernetes/ca.crt"
authorization:
  mode: Webhook
clusterDomain: "cluster.local"
clusterDNS:
  - "10.32.0.10"
podCIDR: "10.64.1.0/24"
resolvConf: "/run/systemd/resolve/resolv.conf"
runtimeRequestTimeout: "15m"
tlsCertFile: "/var/lib/kubelet/kubelet.crt"
tlsPrivateKeyFile: "/var/lib/kubelet/kubelet.key"
EOF

# cp kubelet /usr/local/bin/kubelet

# chmod 755 /usr/local/bin/kubelet

# cat <<EOF >kubelet.service
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/kubernetes/kubernetes
After=containerd.service
Requires=containerd.service

[Service]
ExecStart=/usr/local/bin/kubelet \
  --config=/var/lib/kubelet/kubelet-config.yaml \
  --container-runtime=remote \
  --container-runtime-endpoint=unix:///var/run/containerd/containerd.sock \
  --image-pull-progress-deadline=2m \
  --kubeconfig=/var/lib/kubelet/kubelet.kubeconfig \
  --network-plugin=cni \
  --register-node=true \
  --hostname-override=ecs-matrix-k8s-cluster-2 \
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target

# systemctl daemon-reload

# systemctl start kubelet.service
```

### Verify
```bash
# curl -i http://127.0.0.1:10248/healthz
HTTP/1.1 200 OK
Content-Type: text/plain; charset=utf-8
X-Content-Type-Options: nosniff
Date: Tue, 14 Jun 2022 18:17:06 GMT
Content-Length: 2

ok

# kubectl get nodes
NAME                       STATUS   ROLES    AGE   VERSION
ecs-matrix-k8s-cluster-2   Ready    <none>   19s   v1.21.0

#  curl -s --cacert /etc/etcd/ca.crt  --cert ~/certs/kubelet/kubelet.crt --key ~/certs/kubelet/kubelet.key  https://127.0.0.1:6443/api/v1/nodes | jq '.items[].metadata.name'
"ecs-matrix-k8s-cluster-2"
```

## kube-proxy
### Tool download
```bash
# yum -y install socat conntrack ipset

# wget https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kube-proxy
```

### Certs
`kube-proxy` is authenticated with RBAC rule `system:node-proxier`.
```bash
# kubectl get clusterrolebindings system:node-proxier -o yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  creationTimestamp: "2022-06-11T19:49:53Z"
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  name: system:node-proxier
  resourceVersion: "146"
  uid: 0ff8d8c1-5336-4e44-b5c1-3d444884172f
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:node-proxier
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: User
  name: system:kube-proxy
```
In `kube-proxy` cert, `O` (Organization) should be `system:node-proxier` which aligned with group name `system:node-proxier`. And `CN` (CommanName) should be `system:kube-proxy` which aligned with `subjects` user name.

##### Config
```bash
# cat <<EOF > kube-proxy.cnf
[ ca ]
default_ca      = CA_default            # The default ca section

[ CA_default ]

dir             = /etc/pki/CA           # Where everything is kept
certs           = \$dir/certs            # Where the issued certs are kept
crl_dir         = \$dir/crl              # Where the issued crl are kept
database        = \$dir/index.txt        # database index file.

new_certs_dir   = \$dir/newcerts         # default place for new certs.

certificate     = \$dir/ca.crt           # The CA certificate
serial          = \$dir/serial           # The current serial number
crlnumber       = \$dir/crlnumber        # the current crl number
                                        # must be commented out to leave a V1 CRL
crl             = \$dir/ca.crl           # The current CRL
private_key     = \$dir/private/ca.key   # The private key
RANDFILE        = \$dir/private/.rand    # private random number file

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
organizationName        = optional
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional

[ usr_cert ]
basicConstraints=CA:FALSE
nsComment                       = "OpenSSL Generated Certificate"
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid,issuer
EOF
```

##### Private key
```bash
# openssl genrsa -out kube-proxy.key 2048
```

##### Cert Request
```bash
# openssl req -new -out kube-proxy.csr -key kube-proxy.key
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [XX]:CN
State or Province Name (full name) []:BJ
Locality Name (eg, city) [Default City]:Beijing
Organization Name (eg, company) [Default Company Ltd]:system:node-proxier
Organizational Unit Name (eg, section) []:Matrix
Common Name (eg, your name or your server's hostname) []:system:kube-proxy
Email Address []:root@ecs-matrix-k8s-cluster-2

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:
```

##### Public Cert
```bash
# openssl ca -in kube-proxy.csr -out kube-proxy.crt -config kube-proxy.cnf
```

### Config
```bash
# kubectl config set-cluster ecs-matrix-k8s-cluster-all-in-one --certificate-authority=/etc/etcd/ca.crt --embed-certs=true --server=https://172.16.1.180:6443 --kubeconfig=kube-proxy.kubeconfig

# kubectl config set-credentials system:kube-proxy --client-certificate=/root/certs/kube-proxy/kube-proxy.crt --client-key=/root/certs/kube-proxy/kube-proxy.key --embed-certs=true --kubeconfig=kube-proxy.kubeconfig

# kubectl config set-context default --cluster=ecs-matrix-k8s-cluster-all-in-one --user=system:kube-proxy --kubeconfig=kube-proxy.kubeconfig

# kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig

# mkdir /var/lib/kube-proxy

# cp kube-proxy.kubeconfig /var/lib/kube-proxy/kube-proxy.kubeconfig

# cat <<EOF >kube-proxy-config.yaml
kind: KubeProxyConfiguration
apiVersion: kubeproxy.config.k8s.io/v1alpha1
clientConnection:
  kubeconfig: "/var/lib/kube-proxy/kube-proxy.kubeconfig"
mode: "iptables"
clusterCIDR: "10.64.1.0/24"
EOF

# cat <<EOF >kube-proxy.service
[Unit]
Description=Kubernetes Kube Proxy
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-proxy \\
  --config=/var/lib/kube-proxy/kube-proxy-config.yaml \\
  --hostname-override ecs-matrix-k8s-cluster-2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# cp kube-proxy /usr/local/bin/

# chmod 755 /usr/local/bin/kube-proxy

# systemctl daemon-reload

# systemctl start kube-proxy.service
```

### Verify
```bash
# curl -kv http://127.0.0.1:10249/healthz
* About to connect() to 127.0.0.1 port 10249 (#0)
*   Trying 127.0.0.1...
* Connected to 127.0.0.1 (127.0.0.1) port 10249 (#0)
> GET /healthz HTTP/1.1
> User-Agent: curl/7.29.0
> Host: 127.0.0.1:10249
> Accept: */*
>
< HTTP/1.1 200 OK
< Content-Type: text/plain; charset=utf-8
< X-Content-Type-Options: nosniff
< Date: Tue, 14 Jun 2022 16:47:40 GMT
< Content-Length: 2
<
* Connection #0 to host 127.0.0.1 left intact
ok

# curl http://127.0.0.1:10249/metrics
...snippets...
apiserver_audit_event_total 0
apiserver_audit_requests_rejected_total 0
go_gc_duration_seconds{quantile="0"} 3.3899e-05
go_gc_duration_seconds{quantile="0.25"} 3.8321e-05
go_gc_duration_seconds{quantile="0.5"} 4.9986e-05
go_gc_duration_seconds{quantile="0.75"} 6.9362e-05
go_gc_duration_seconds{quantile="1"} 0.000201038
go_gc_duration_seconds_sum 0.001537893
...snippets...
```

## kube-scheduler
### Tool download
```bash
# wget https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kube-scheduler
```

### Certs
same auth as `kube-proxy`
```bash
# kubectl get clusterrolebindings system:kube-scheduler -o yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  creationTimestamp: "2022-04-23T20:12:28Z"
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  name: system:kube-scheduler
  resourceVersion: "149"
  uid: b0e03403-9787-4829-bac7-96cfe4c9c0f9
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:kube-scheduler
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: User
  name: system:kube-scheduler
```

##### config
```bash
# cat <<EOF >scheduler.cnf
[ ca ]
default_ca      = CA_default            # The default ca section

[ CA_default ]

dir             = /etc/pki/CA           # Where everything is kept
certs           = \$dir/certs            # Where the issued certs are kept
crl_dir         = \$dir/crl              # Where the issued crl are kept
database        = \$dir/index.txt        # database index file.

new_certs_dir   = \$dir/newcerts         # default place for new certs.

certificate     = \$dir/ca.crt           # The CA certificate
serial          = \$dir/serial           # The current serial number
crlnumber       = \$dir/crlnumber        # the current crl number
                                        # must be commented out to leave a V1 CRL
crl             = \$dir/ca.crl           # The current CRL
private_key     = \$dir/private/ca.key   # The private key
RANDFILE        = \$dir/private/.rand    # private random number file

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
organizationName        = optional
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional

[ usr_cert ]

basicConstraints=CA:FALSE
nsComment                       = "OpenSSL Generated Certificate"
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid,issuer
EOF
```

##### Private key
```bash
# openssl genrsa -out scheduler.key 2048
```

##### Cert Request
```bash
# openssl req -new -out scheduler.csr -key scheduler.key
Generating RSA private key, 2048 bit long modulus
..+++
...........................................+++
e is 65537 (0x10001)
[root@ecs-matrix-k8s-cluster-2 scheduler]# openssl req -new -out scheduler.csr -key scheduler.key
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [XX]:CN
State or Province Name (full name) []:BJ
Locality Name (eg, city) [Default City]:Beijing
Organization Name (eg, company) [Default Company Ltd]:system:kube-scheduler
Organizational Unit Name (eg, section) []:ecs-matrix-k8s-cluster-2
Common Name (eg, your name or your server's hostname) []:system:kube-scheduler
Email Address []:root@ecs-matrix-k8s-cluster-2

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:
```

##### Public Cert
```bash
# openssl ca -in scheduler.csr -out scheduler.crt -config scheduler.cnf
```

### Config
```bash
# kubectl config set-cluster ecs-matrix-k8s-cluster-all-in-one --certificate-authority=/etc/etcd/ca.crt --embed-certs=true --server=https://127.0.0.1:6443 --kubeconfig=kube-scheduler.kubeconfig

# kubectl config set-credentials system:kube-scheduler --client-certificate=/root/certs/scheduler/scheduler.crt --client-key=/root/certs/scheduler/scheduler.key --embed-certs=true --kubeconfig=kube-scheduler.kubeconfig

# kubectl config set-context default --cluster=ecs-matrix-k8s-cluster-all-in-one --user=system:kube-scheduler --kubeconfig=kube-scheduler.kubeconfig

# kubectl config use-context default --kubeconfig=kube-scheduler.kubeconfig

# cp kube-scheduler.kubeconfig /var/lib/kubernetes/kube-scheduler.kubeconfig

# cat <<EOF > kube-scheduler.yaml
apiVersion: kubescheduler.config.k8s.io/v1beta1
kind: KubeSchedulerConfiguration
clientConnection:
  kubeconfig: "/var/lib/kubernetes/kube-scheduler.kubeconfig"
leaderElection:
  leaderElect: true
EOF

# mkdir -p /etc/kubernetes/config/

# cp kube-scheduler.yaml /etc/kubernetes/config/

# cp kube-scheduler /usr/local/bin/

# chmod 755 /usr/local/bin/kube-scheduler

# cat <<EOF > kube-scheduler.service
[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-scheduler --config=/etc/kubernetes/config/kube-scheduler.yaml --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```

### Verify
```bash
#  curl -v http://127.0.0.1:10251/healthz
* About to connect() to 127.0.0.1 port 10251 (#0)
*   Trying 127.0.0.1...
* Connected to 127.0.0.1 (127.0.0.1) port 10251 (#0)
> GET /healthz HTTP/1.1
> User-Agent: curl/7.29.0
> Host: 127.0.0.1:10251
> Accept: */*
>
< HTTP/1.1 200 OK
< Cache-Control: no-cache, private
< Content-Type: text/plain; charset=utf-8
< X-Content-Type-Options: nosniff
< Date: Sun, 12 Jun 2022 19:06:56 GMT
< Content-Length: 2
<
* Connection #0 to host 127.0.0.1 left intact
ok

# kubectl get cs scheduler
Warning: v1 ComponentStatus is deprecated in v1.19+
NAME        STATUS    MESSAGE   ERROR
scheduler   Healthy   ok
```

## kube-controller-manager
### Tool download
```bash
# wget https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kube-controller-manager
```

### Cert
same auth as kube-proxy
```bash
# kubectl get clusterrolebindings system:kube-controller-manager -o yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  creationTimestamp: "2022-06-11T19:49:53Z"
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  name: system:kube-controller-manager
  resourceVersion: "147"
  uid: 808c97e8-279d-4716-a0e7-d00c84becd26
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:kube-controller-manager
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: User
  name: system:kube-controller-manager
```

##### config
```bash
# cat <<EOF >controller-manager.cnf
[ ca ]
default_ca      = CA_default            # The default ca section

[ CA_default ]

dir             = /etc/pki/CA           # Where everything is kept
certs           = \$dir/certs            # Where the issued certs are kept
crl_dir         = \$dir/crl              # Where the issued crl are kept
database        = \$dir/index.txt        # database index file.

new_certs_dir   = \$dir/newcerts         # default place for new certs.

certificate     = \$dir/ca.crt           # The CA certificate
serial          = \$dir/serial           # The current serial number
crlnumber       = \$dir/crlnumber        # the current crl number
                                        # must be commented out to leave a V1 CRL
crl             = \$dir/ca.crl           # The current CRL
private_key     = \$dir/private/ca.key   # The private key
RANDFILE        = \$dir/private/.rand    # private random number file

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
organizationName        = optional
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional

[ usr_cert ]
basicConstraints=CA:FALSE
nsComment                       = "OpenSSL Generated Certificate"
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid,issuer
EOF
```

##### Private key
```bash
# openssl genrsa -out controller-manager.key 2048
```

##### Cert Request
```bash
# openssl req -new -out controller-manager.csr -key controller-manager.key
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [XX]:CN
State or Province Name (full name) []:BJ
Locality Name (eg, city) [Default City]:Beijing
Organization Name (eg, company) [Default Company Ltd]:system:kube-controller-manager
Organizational Unit Name (eg, section) []:Matrix
Common Name (eg, your name or your server's hostname) []:system:kube-controller-manager
Email Address []:root@ecs-matrix-k8s-cluster-2

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:
```

##### Public Cert
```bash
# openssl ca -in controller-manager.csr -out controller-manager.crt -config controller-manager.cnf
```

### Config
```bash
# cp controller-manager.crt /var/lib/kubernetes/controller-manager.crt

# sed -E -i '/service-account-key-file/s/apiserver.crt/controller-manager.crt/' /etc/systemd/system/kube-apiserver.service

# sed -E -i '/service-account-signing-key-file/s/apiserver.key/controller-manager.key/' /etc/systemd/system/kube-apiserver.service

# systemctl daemon-reload

# systemctl restart kube-apiserver.service

# kubectl config set-cluster ecs-matrix-k8s-cluster-all-in-one  --certificate-authority=/etc/etcd/ca.crt --embed-certs=true --server=https://127.0.0.1:6443 --kubeconfig=controller-manager.kubeconfig

# kubectl config set-credentials system:kube-controller-manager --client-certificate=/root/certs/controller-manager/controller-manager.crt --client-key=/root/certs/controller-manager/controller-manager.key --embed-certs=true --kubeconfig=controller-manager.kubeconfig

# kubectl config set-context default --cluster=ecs-matrix-k8s-cluster-all-in-one --user=system:kube-controller-manager --kubeconfig=controller-manager.kubeconfig

# kubectl config use-context default --kubeconfig=controller-manager.kubeconfig

# openssl rsa -in /etc/pki/CA/private/ca.key  > ca.key

# cp ca.key /var/lib/kubernetes/ca.key

# cp controller-manager.key /var/lib/kubernetes/controller-manager.key

# cp controller-manager.kubeconfig /var/lib/kubernetes/kube-controller-manager.kubeconfig

# cp kube-controller-manager /usr/local/bin/kube-controller-manager

# chmod 755 /usr/local/bin/kube-controller-manager

# cat <<EOF > /etc/systemd/system/kube-controller-manager.service
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-controller-manager \
  --bind-address=0.0.0.0 \
  --cluster-cidr=10.64.0.0/16 \
  --cluster-name=kubernetes \
  --cluster-signing-cert-file=/var/lib/kubernetes/ca.crt \
  --cluster-signing-key-file=/var/lib/kubernetes/ca.key \
  --kubeconfig=/var/lib/kubernetes/kube-controller-manager.kubeconfig \
  --leader-elect=true \
  --root-ca-file=/var/lib/kubernetes/ca.crt \
  --service-account-private-key-file=/var/lib/kubernetes/controller-manager.key \
  --service-cluster-ip-range=10.32.0.0/24 \
  --use-service-account-credentials=true \
  --v=2
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# systemctl daemon-reload

# systemctl start kube-controller-manager.service
```

### Verify
```bash
# kubectl get cs controller-manager
Warning: v1 ComponentStatus is deprecated in v1.19+
NAME                 STATUS    MESSAGE   ERROR
controller-manager   Healthy   ok

# curl -i http://127.0.0.1:10252/healthz
HTTP/1.1 200 OK
Cache-Control: no-cache, private
Content-Type: text/plain; charset=utf-8
X-Content-Type-Options: nosniff
Date: Tue, 14 Jun 2022 17:44:44 GMT
Content-Length: 2

ok
```

## coredns add-on
### Deploy
```bash
# cat <<EOF > coredns-1.8.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: coredns
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  name: system:coredns
rules:
- apiGroups:
  - ""
  resources:
  - endpoints
  - services
  - pods
  - namespaces
  verbs:
  - list
  - watch
- apiGroups:
  - ""
  resources:
  - nodes
  verbs:
  - get
- apiGroups:
  - discovery.k8s.io
  resources:
  - endpointslices
  verbs:
  - list
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  name: system:coredns
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:coredns
subjects:
- kind: ServiceAccount
  name: coredns
  namespace: kube-system
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
data:
  Corefile: |
    .:53 {
        template ANY HINFO . {
            rcode NXDOMAIN
        }
        log
        errors
        health
        ready
        kubernetes cluster.local in-addr.arpa ip6.arpa {
          pods insecure
          fallthrough in-addr.arpa ip6.arpa
        }
        prometheus :9153
        forward . /etc/resolv.conf
        cache 30
        loop
        reload
        loadbalance
    }
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: coredns
  namespace: kube-system
  labels:
    k8s-app: kube-dns
    kubernetes.io/name: "CoreDNS"
spec:
  replicas: 1
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
  selector:
    matchLabels:
      k8s-app: kube-dns
  template:
    metadata:
      labels:
        k8s-app: kube-dns
    spec:
      priorityClassName: system-cluster-critical
      serviceAccountName: coredns
      tolerations:
        - key: "CriticalAddonsOnly"
          operator: "Exists"
      nodeSelector:
        beta.kubernetes.io/os: linux
      containers:
      - name: coredns
        image: coredns/coredns:1.8.3
        imagePullPolicy: IfNotPresent
        resources:
          limits:
            memory: 170Mi
          requests:
            cpu: 100m
            memory: 70Mi
        args: [ "-conf", "/etc/coredns/Corefile" ]
        volumeMounts:
        - name: config-volume
          mountPath: /etc/coredns
          readOnly: true
        ports:
        - containerPort: 53
          name: dns
          protocol: UDP
        - containerPort: 53
          name: dns-tcp
          protocol: TCP
        - containerPort: 9153
          name: metrics
          protocol: TCP
        securityContext:
          allowPrivilegeEscalation: false
          capabilities:
            add:
            - NET_BIND_SERVICE
            drop:
            - all
          readOnlyRootFilesystem: true
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
            scheme: HTTP
          initialDelaySeconds: 60
          timeoutSeconds: 5
          successThreshold: 1
          failureThreshold: 5
        readinessProbe:
          httpGet:
            path: /ready
            port: 8181
            scheme: HTTP
      dnsPolicy: Default
      volumes:
        - name: config-volume
          configMap:
            name: coredns
            items:
            - key: Corefile
              path: Corefile
---
apiVersion: v1
kind: Service
metadata:
  name: kube-dns
  namespace: kube-system
  annotations:
    prometheus.io/port: "9153"
    prometheus.io/scrape: "true"
  labels:
    k8s-app: kube-dns
    kubernetes.io/cluster-service: "true"
    kubernetes.io/name: "CoreDNS"
spec:
  selector:
    k8s-app: kube-dns
  clusterIP: 10.32.0.10
  ports:
  - name: dns
    port: 53
    protocol: UDP
  - name: dns-tcp
    port: 53
    protocol: TCP
  - name: metrics
    port: 9153
    protocol: TCP
EOF

# kubectl apply -f coredns-1.8.yaml
```

### Verify
```bash
# kubectl run busybox --image=busybox:1.28 --command -- sleep 3600

# kubectl exec -ti busybox -- nslookup kubernetes
Server:    10.32.0.10
Address 1: 10.32.0.10 kube-dns.kube-system.svc.cluster.local

Name:      kubernetes
Address 1: 10.32.0.1 kubernetes.default.svc.cluster.local

# kubectl exec -ti busybox -- nslookup www.google.com
Server:    10.32.0.10
Address 1: 10.32.0.10 kube-dns.kube-system.svc.cluster.local

Name:      www.google.com
Address 1: 2a00:1450:4019:801::2004 fjr02s09-in-x04.1e100.net
Address 2: 172.217.19.164 zrh04s07-in-f4.1e100.net

# kubectl get pods -n kube-system -o wide
NAME                       READY   STATUS    RESTARTS   AGE   IP          NODE                       NOMINATED NODE   READINESS GATES
coredns-8494f9c688-j2dbg   1/1     Running   0          24h   10.64.1.7   ecs-matrix-k8s-cluster-2   <none>           <none>

# ping -c1 -w1 10.64.1.7
PING 10.64.1.7 (10.64.1.7): 56 data bytes
64 bytes from 10.64.1.7: seq=0 ttl=64 time=0.068 ms

--- 10.64.1.7 ping statistics ---
1 packets transmitted, 1 packets received, 0% packet loss
round-trip min/avg/max = 0.068/0.068/0.068 ms
```

## Test
```bash 
# kubectl create deployment nginx --image=nginx

# kubectl get pods -l app=nginx
NAME                     READY   STATUS    RESTARTS   AGE
nginx-6799fc88d8-stvrl   1/1     Running   0          79s

# kubectl port-forward nginx-6799fc88d8-stvrl 8080:80
Forwarding from 127.0.0.1:8080 -> 80
Forwarding from [::1]:8080 -> 80

# curl --head http://127.0.0.1:8080
HTTP/1.1 200 OK
Server: nginx/1.21.6
Date: Wed, 15 Jun 2022 19:29:18 GMT
Content-Type: text/html
Content-Length: 615
Last-Modified: Tue, 25 Jan 2022 15:03:52 GMT
Connection: keep-alive
ETag: "61f01158-267"
Accept-Ranges: bytes

# kubectl logs nginx-6799fc88d8-stvrl
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
10-listen-on-ipv6-by-default.sh: info: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
/docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
/docker-entrypoint.sh: Configuration complete; ready for start up
2022/06/15 19:26:34 [notice] 1#1: using the "epoll" event method
2022/06/15 19:26:34 [notice] 1#1: nginx/1.21.6
2022/06/15 19:26:34 [notice] 1#1: built by gcc 10.2.1 20210110 (Debian 10.2.1-6)
2022/06/15 19:26:34 [notice] 1#1: OS: Linux 3.10.0-957.27.2.el7.x86_64
2022/06/15 19:26:34 [notice] 1#1: getrlimit(RLIMIT_NOFILE): 1048576:1048576
2022/06/15 19:26:34 [notice] 1#1: start worker processes
2022/06/15 19:26:34 [notice] 1#1: start worker process 30
2022/06/15 19:26:34 [notice] 1#1: start worker process 31
127.0.0.1 - - [15/Jun/2022:19:28:58 +0000] "GET / HTTP/1.1" 200 615 "-" "curl/7.29.0" "-"
127.0.0.1 - - [15/Jun/2022:19:29:18 +0000] "HEAD / HTTP/1.1" 200 0 "-" "curl/7.29.0" "-"

# kubectl exec -ti nginx-6799fc88d8-stvrl -- nginx -v
nginx version: nginx/1.21.6

# kubectl expose deployment nginx --port 80 --type NodePort
service/nginx exposed

# kubectl get svc nginx -o jsonpath='{range .spec.ports[0]}{.nodePort}'
31824

# curl -I http://localhost:31824
HTTP/1.1 200 OK
Server: nginx/1.21.6
Date: Wed, 15 Jun 2022 19:32:31 GMT
Content-Type: text/html
Content-Length: 615
Last-Modified: Tue, 25 Jan 2022 15:03:52 GMT
Connection: keep-alive
ETag: "61f01158-267"
Accept-Ranges: bytes

# kubectl exec -ti  busybox -- nslookup nginx
Server:    10.32.0.10
Address 1: 10.32.0.10 kube-dns.kube-system.svc.cluster.local

Name:      nginx
Address 1: 10.32.0.223 nginx.default.svc.cluster.local

# kubectl delete deployment nginx
deployment.apps "nginx" deleted

# kubectl delete svc nginx
service "nginx" deleted
```