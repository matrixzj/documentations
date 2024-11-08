---
title: Kubernetes All-in-One Deployment in the Hard Way 
tags: [container]
keywords: kubernetes, k8s
last_updated: Jul 4, 2024
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
| cluster-name | | ecs-matrix-k8s-cluster-all-in-one | kubeconfig files |   
| service-cluster-ip-range | A CIDR IP range from which to assign service cluster IPs | 10.32.0.0/24 | kube-apiserver.service, kube-controller-manager.service |   
| cluster-cidr | CIDR Range for Pods in cluster | 10.64.0.0/22 | kube-proxy-config.yaml, kube-controller-manager.service |    
| podCIDR for node 1 | pod subnet for master node | 10.64.1.0/24 | 10-bridge.conf, kubelet-config.yaml |   
| podCIDR for node 2 | pod subnet for worker node | 10.64.2.0/24 | 10-bridge.conf, kubelet-config.yaml |  

```bash
sudo /usr/sbin/setenforce 0 
sudo sed -i '/SELINUX=/s/enforcing/disabled/' /etc/sysconfig/selinux
```
Config `/etc/hosts` file for dns resolve. 
Env Variables
```bash
cat <<EOF>> .bashrc
export SVC_CIDR='10.32.0.0/24'
export CLUSTER_CIDR='10.64.0.0/22'
export CLUSTER_NAME='ecs-matrix-k8s-cluster-all-in-one'

export IP_MASTER='192.168.50.74'
export HOSTNAME_MASTER='ecs-matrix-k8s-cluster-master'
export POD_CIDR_MASTER='10.64.0.0/24'

export CA_KEY_PASS='*@55Ka}5'

export kube_ver='1.30.2'
export etcd_ver='3.4.33'
export crictl_ver='1.30.0'
export runc_ver='1.1.13'
export cni_ver='1.5.1'
export containerd_ver='1.7.18'
EOF
```

## CA
In Kubernetes authorization `RBAC` 
* to authorized with a `group` in `rolebinding` / `clusterrolebing`, `group` should be aligned with `O` (Organization) in client cert.
* to authorized with a `user` in `rolebinding` / `clusterrolebing`, `user` should be aligned with `CN` (CommanName) in client cert.

### Config
```bash
[ -d ca ] || mkdir ca && cat <<EOF> ca/ca.cnf
[ ca ]
default_ca      = CA_default            # The default ca section

[ CA_default ]
dir             = $(pwd)/ca       # Where everything is kept
certs           = \$dir/certs            # Where the issued certs are kept
crl_dir         = \$dir/crl              # Where the issued crl are kept
database        = \$dir/index.txt        # database index file.
                                        # several ctificates with same subject.
new_certs_dir   = \$dir/newcerts         # default place for new certs.
certificate     = \$dir/ca.crt           # The CA certificate
serial          = \$dir/serial           # The current serial number
crlnumber       = \$dir/crlnumber        # the current crl number
                                        # must be commented out to leave a V1 CRL
crl             = \$dir/ca.crl           # The current CRL
private_key     = \$dir/ca.key           # The private key
default_days    = 365                   # how long to certify for
default_crl_days= 30                    # how long before next CRL
default_md      = sha256                # use SHA-256 by default
preserve        = no                    # keep passed DN ordering
policy          = policy_match

[ policy_match ]
countryName             = match
stateOrProvinceName     = match
organizationName        = supplied
organizationalUnitName  = supplied
commonName              = supplied
emailAddress            = optional

[ req ]
distinguished_name      = req_distinguished_name
req_extensions          = root_ca        

[ req_distinguished_name ]
countryName                     = Country Name (2 letter code)
stateOrProvinceName             = State or Province Name (full name)
localityName                    = Locality Name (eg, city)
0.organizationName              = Organization Name (eg, company)
organizationalUnitName          = Organizational Unit Name (eg, section)
commonName                      = Common Name (eg, your name or your server\'s hostname)

[ root_ca ]
subjectKeyIdentifier            = hash
authorityKeyIdentifier          = keyid:always,issuer
basicConstraints                = CA:true
keyUsage                        = critical, keyCertSign, cRLSign
crlDistributionPoints           = @crl_section

[ crl_section ]
URI.1                           = http://localhost/root-ca.crl

# For \`admin\` / \`kube-proxy\`
[ usr_cert_no_alt ]
basicConstraints                = CA:false
keyUsage                        = critical, digitalSignature, keyEncipherment

# For \`kube-apiserver\`
[ usr_cert_kube_apiserver ]
basicConstraints                = CA:false
keyUsage                        = critical, digitalSignature, keyEncipherment
subjectAltName                  = @alt_names_kube_apiserver

[ alt_names_kube_apiserver ]
DNS.1 = kubernetes
DNS.2 = kubernetes.default
DNS.3 = kubernetes.default.svc
DNS.4 = kubernetes.default.svc.cluster
DNS.5 = kubernetes.svc.cluster.local
DNS.7 = ${HOSTNAME_MASTER}
IP.1 = 127.0.0.1
IP.2 = 10.32.0.1
IP.3 = ${IP_MASTER}

# For \`etcd\` / \`kubelet\` / \`kube-scheduler\` / \`kube-controller-manager\`
[ usr_cert_alts ]
basicConstraints                = CA:false
keyUsage                        = critical, digitalSignature, keyEncipherment
subjectAltName                  = @alt_names_alts

[ alt_names_alts ]
DNS.1 = localhost
DNS.2 = ${HOSTNAME_MASTER}
IP.1 = 127.0.0.1
IP.2 = ${IP_MASTER}
EOF

mkdir ca/newcerts
touch ca/index.txt
echo 01 >> ca/serial
```

### CA Cert
```bash
# Private Key
openssl genrsa -passout pass:"$CA_KEY_PASS" -out ca/ca.key -des3 2048
chmod 600 ca/ca.key

# Public Cert
openssl req -new -x509 -key ca/ca.key -days 3650 -subj "/C=CN/ST=BJ/L=Beijing/O=${CLUSTER_NAME}/OU=Matrix/CN=Kubernetes-CA" -config ca/ca.cnf -extensions root_ca -passin pass:"$CA_KEY_PASS" > ca/ca.crt
```

### `etcd` Cert
```bash
[ -d etcd ] || mkdir etcd
# Private Key
openssl genrsa -out etcd/etcd.key 2048
# Cert Request
openssl req -new -out etcd/etcd.csr -key etcd/etcd.key -config ca/ca.cnf -subj "/C=CN/ST=BJ/L=Beijing/O=${CLUSTER_NAME}/OU=Matrix/CN=etcd" -reqexts usr_cert_alts 
# Public Cert
openssl ca -in etcd/etcd.csr -out etcd/etcd.crt -notext -config ca/ca.cnf -subj "/C=CN/ST=BJ/L=Beijing/O=${CLUSTER_NAME}/OU=Matrix/CN=etcd" -extensions usr_cert_alts -passin pass:"$CA_KEY_PASS" -batch
```

### `kube-apiserver` Cert
```bash
[ -d kube-apiserver ] || mkdir kube-apiserver
# Private Key
openssl genrsa -out kube-apiserver/kube-apiserver.key 2048
# Cert Request
openssl req -new -out kube-apiserver/kube-apiserver.csr -key kube-apiserver/kube-apiserver.key -config ca/ca.cnf -subj "/C=CN/ST=BJ/L=Beijing/O=${CLUSTER_NAME}/OU=Matrix/CN=kube-apiserver" -reqexts usr_cert_kube_apiserver 
# Public Cert
openssl ca -in kube-apiserver/kube-apiserver.csr -out kube-apiserver/kube-apiserver.crt -notext -config ca/ca.cnf -subj "/C=CN/ST=BJ/L=Beijing/O=${CLUSTER_NAME}/OU=Matrix/CN=kube-apiserver" -extensions usr_cert_kube_apiserver -passin pass:"$CA_KEY_PASS" -batch
```

### `admin` Cert
`kube-proxy` is authenticated with clusterrolebinding `cluster-admin`
```bash
$ kubectl get clusterrolebindings.rbac.authorization.k8s.io cluster-admin -o json | jq -r '.subjects[] | { Kind: .kind, Name: .name }'
{
  "Kind": "Group",
  "Name": "system:masters"
}
```

```bash
[ -d admin ] || mkdir admin
# Private Key
openssl genrsa -out admin/admin.key 2048
# Cert Request
openssl req -new -out admin/admin.csr -key admin/admin.key -config ca/ca.cnf -subj '/C=CN/ST=BJ/L=Beijing/O=system:masters/OU=Matrix/CN=kube-admin' -reqexts usr_cert_no_alt
# Public Cert
openssl ca -in admin/admin.csr -out admin/admin.crt -notext -config ca/ca.cnf -subj '/C=CN/ST=BJ/L=Beijing/O=system:masters/OU=Matrix/CN=kube-admin' -extensions usr_cert_no_alt -passin pass:"$CA_KEY_PASS" -batch
```

### `kubelet` Cert
In order to be authorized by the Node authorizer, kubelets must use a credential that identifies them as being in the `system:nodes` group, with a username of `system:node:<nodeName>`. By default, `nodeName` is the host name as provided by `hostname`, or overridden via the kubelet option `--hostname-override`.
Ref: [Kubernetes Using Node Authorization](https://kubernetes.io/docs/reference/access-authn-authz/node/) 
```bash
[ -d kubelet ] || mkdir kubelet
# Private Key
openssl genrsa -out kubelet/kubelet.key 2048
# Cert Request
openssl req -new -out kubelet/kubelet.csr -key kubelet/kubelet.key -config ca/ca.cnf -subj "/C=CN/ST=BJ/L=Beijing/O=system:nodes/OU=Matrix/CN=system:node:${HOSTNAME_MASTER}" -reqexts usr_cert_alts
# Public Cert
openssl ca -in kubelet/kubelet.csr -out kubelet/kubelet.crt -notext -config ca/ca.cnf -subj "/C=CN/ST=BJ/L=Beijing/O=system:nodes/OU=Matrix/CN=system:node:${HOSTNAME_MASTER}" -extensions usr_cert_alts -passin pass:"$CA_KEY_PASS" -batch
```

### `kube-proxy` Cert
`kube-proxy` is authenticated with clusterrolebinding `system:node-proxier`
```bash
$ kubectl get clusterrolebindings.rbac.authorization.k8s.io system:node-proxier -o json | jq -r '.subjects[] | { Kind: .kind, Name: .name }'
{
  "Kind": "User",
  "Name": "system:kube-proxy"
}
```
```bash
[ -d kube-proxy ] || mkdir kube-proxy
# Private Key
openssl genrsa -out kube-proxy/kube-proxy.key 2048
# Cert Request
openssl req -new -out kube-proxy/kube-proxy.csr -key kube-proxy/kube-proxy.key -config ca/ca.cnf -subj "/C=CN/ST=BJ/L=Beijing/O=${CLUSTER_NAME}/OU=Matrix/CN=system:kube-proxy" -reqexts usr_cert_no_alt
# Public Cert
openssl ca -in kube-proxy/kube-proxy.csr -out kube-proxy/kube-proxy.crt -notext -config ca/ca.cnf -subj "/C=CN/ST=BJ/L=Beijing/O=${CLUSTER_NAME}/OU=Matrix/CN=system:kube-proxy" -extensions usr_cert_no_alt -passin pass:"$CA_KEY_PASS" -batch
```

### `kube-scheduler` Cert
`kube-scheduler` is authenticated with clusterrolebinding `system:kube-scheduler`
```bash
$ kubectl get clusterrolebindings.rbac.authorization.k8s.io system:kube-scheduler -o json | jq -r '.subjects[] | { Kind: .kind, Name: .name }'
{
  "Kind": "User",
  "Name": "system:kube-scheduler"
}
```
```bash
[ -d kube-scheduler ] || mkdir kube-scheduler
# Private Key
openssl genrsa -out kube-scheduler/kube-scheduler.key 2048
# Cert Request
openssl req -new -out kube-scheduler/kube-scheduler.csr -key kube-scheduler/kube-scheduler.key -config ca/ca.cnf -subj "/C=CN/ST=BJ/L=Beijing/O=${CLUSTER_NAME}/OU=Matrix/CN=system:kube-scheduler" -reqexts usr_cert_alts
# Public Cert
openssl ca -in kube-scheduler/kube-scheduler.csr -out kube-scheduler/kube-scheduler.crt -notext -config ca/ca.cnf -subj "/C=CN/ST=BJ/L=Beijing/O=${CLUSTER_NAME}/OU=Matrix/CN=system:kube-scheduler" -extensions usr_cert_alts -passin pass:"$CA_KEY_PASS" -batch
```

### `kube-controller-manager` Cert
`kube-scheduler` is authenticated with clusterrolebinding `system:kube-controller-manager`
```bash
$ kubectl get clusterrolebindings.rbac.authorization.k8s.io system:kube-controller-manager -o json | jq -r '.subjects[] | { Kind: .kind, Name: .name }'
{
  "Kind": "User",
  "Name": "system:kube-controller-manager"
}
```
```bash
[ -d kube-controller-manager ] || mkdir kube-controller-manager
# Private Key
openssl genrsa -out kube-controller-manager/kube-controller-manager.key 2048
# Cert Request
openssl req -new -out kube-controller-manager/kube-controller-manager.csr -key kube-controller-manager/kube-controller-manager.key -config ca/ca.cnf -subj "/C=CN/ST=BJ/L=Beijing/O=${CLUSTER_NAME}/OU=Matrix/CN=system:kube-controller-manager" -reqexts usr_cert_alts
# Public Cert
openssl ca -in kube-controller-manager/kube-controller-manager.csr -out kube-controller-manager/kube-controller-manager.crt -notext -config ca/ca.cnf -subj "/C=CN/ST=BJ/L=Beijing/O=${CLUSTER_NAME}/OU=Matrix/CN=system:kube-controller-manager" -extensions usr_cert_alts -passin pass:"$CA_KEY_PASS" -batch
```

## etcd 
### Tools Download
```bash
[ -d etcd ] || mkdir etcd
curl -s -L "https://github.com/etcd-io/etcd/releases/download/v${etcd_ver}/etcd-v${etcd_ver}-linux-amd64.tar.gz" -o "etcd/etcd-v${etcd_ver}-linux-amd64.tar.gz"
```

### Config
```bash
cat <<EOF> etcd/etcd.service
[Unit]
Description=etcd
Documentation=https://github.com/coreos

[Service]
Type=notify
ExecStart=/usr/local/bin/etcd \\
  --name ${HOSTNAME_MASTER} \\
  --cert-file=/etc/etcd/etcd.crt \\
  --key-file=/etc/etcd/etcd.key \\
  --peer-cert-file=/etc/etcd/etcd.crt \\
  --peer-key-file=/etc/etcd/etcd.key \\
  --trusted-ca-file=/etc/etcd/ca.crt \\
  --peer-trusted-ca-file=/etc/etcd/ca.crt \\
  --peer-client-cert-auth \\
  --client-cert-auth \\
  --initial-advertise-peer-urls https://${IP_MASTER}:2380 \\
  --listen-peer-urls https://${IP_MASTER}:2380 \\
  --listen-client-urls https://${IP_MASTER}:2379,https://127.0.0.1:2379 \\
  --advertise-client-urls https://${IP_MASTER}:2379 \\
  --initial-cluster ${HOSTNAME_MASTER}=https://${IP_MASTER}:2380 \\
  --initial-cluster-state new \\
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```

### Deployment 
```bash
tar xf "etcd/etcd-v${etcd_ver}-linux-amd64.tar.gz" -C etcd/
sudo cp -v etcd/etcd-v${etcd_ver}-linux-amd64/etcd* /usr/local/bin/

sudo mkdir -p /etc/etcd
sudo mkdir -p /var/lib/etcd && sudo chmod 700 /var/lib/etcd
sudo cp -v ca/ca.crt /etc/etcd/ca.crt
sudo cp -v etcd/etcd.crt /etc/etcd/etcd.crt
sudo cp -v etcd/etcd.key /etc/etcd/etcd.key

sudo cp -v etcd/etcd.service /etc/systemd/system/etcd.service
sudo systemctl daemon-reload
sudo systemctl enable --now etcd.service
```

### Verify
```bash
$ ETCDCTL_API=3 /usr/local/bin/etcdctl member list --endpoints=https://127.0.0.1:2379 --cacert=/etc/etcd/ca.crt --cert=/etc/etcd/etcd.crt --key=/etc/etcd/etcd.key -w table
+------------------+---------+---------------------------------+-----------------------------+-----------------------------+------------+
|        ID        | STATUS  |              NAME               |         PEER ADDRS          |        CLIENT ADDRS         | IS LEARNER |
+------------------+---------+---------------------------------+-----------------------------+-----------------------------+------------+
| d113b8292a777974 | started | ecs-matrix-k8s-cluster-master01 | https://192.168.50.105:2380 | https://192.168.50.105:2379 |      false |
+------------------+---------+---------------------------------+-----------------------------+-----------------------------+------------+
```

## kube-apiserver
### Tools Download
```bash
[ -d kube-apiserver ] || mkdir -p kube-apiserver
curl -s -L "https://storage.googleapis.com/kubernetes-release/release/v${kube_ver}/bin/linux/amd64/kube-apiserver" -o "kube-apiserver/kube-apiserver-v${kube_ver}"
```

### Config
```bash
cat <<EOF> kube-apiserver/kube-apiserver.service
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-apiserver-v${kube_ver} \\
  --advertise-address=${IP_MASTER} \\
  --allow-privileged=true \\
  --apiserver-count=3 \\
  --audit-log-maxage=30 \\
  --audit-log-maxbackup=3 \\
  --audit-log-maxsize=100 \\
  --audit-log-path=/var/log/audit.log \\
  --authorization-mode=Node,RBAC \\
  --bind-address=0.0.0.0 \\
  --client-ca-file=/var/lib/kubernetes/ca.crt \\
  --enable-admission-plugins=NamespaceLifecycle,NodeRestriction,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota \\
  --etcd-cafile=/var/lib/kubernetes/ca.crt \\
  --etcd-certfile=/var/lib/kubernetes/kube-apiserver.crt \\
  --etcd-keyfile=/var/lib/kubernetes/kube-apiserver.key \\
  --etcd-servers=https://${IP_MASTER}:2379 \\
  --event-ttl=1h \\
  --kubelet-certificate-authority=/var/lib/kubernetes/ca.crt \\
  --kubelet-client-certificate=/var/lib/kubernetes/kube-apiserver.crt \\
  --kubelet-client-key=/var/lib/kubernetes/kube-apiserver.key \\
  --runtime-config=api/all=true \\
  --service-account-issuer=https://${IP_MASTER}:6443 \\
  --service-account-key-file=/var/lib/kubernetes/kube-controller-manager.crt \\
  --service-account-signing-key-file=/var/lib/kubernetes/kube-controller-manager.key \\
  --service-cluster-ip-range=${SVC_CIDR} \\
  --service-node-port-range=30000-32767 \\
  --tls-cert-file=/var/lib/kubernetes/kube-apiserver.crt \\
  --tls-private-key-file=/var/lib/kubernetes/kube-apiserver.key \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```

### Deployment
```bash
sudo cp -v "kube-apiserver/kube-apiserver-v${kube_ver}" "/usr/local/bin/kube-apiserver-v${kube_ver}" && sudo chmod -v 755 "/usr/local/bin/kube-apiserver-v${kube_ver}"

sudo mkdir -p /var/lib/kubernetes/
sudo cp -v ca/ca.crt /var/lib/kubernetes/ca.crt
sudo cp -v kube-apiserver/kube-apiserver.crt /var/lib/kubernetes/kube-apiserver.crt
sudo cp -v kube-apiserver/kube-apiserver.key /var/lib/kubernetes/kube-apiserver.key
sudo cp -v kube-controller-manager/kube-controller-manager.crt /var/lib/kubernetes/kube-controller-manager.crt
sudo cp -v kube-controller-manager/kube-controller-manager.key /var/lib/kubernetes/kube-controller-manager.key

sudo cp -v kube-apiserver/kube-apiserver.service /etc/systemd/system/kube-apiserver.service
sudo systemctl daemon-reload
sudo systemctl enable --now kube-apiserver.service
```

### Verify
```bash
$ curl --cacert ca/ca.crt https://127.0.0.1:6443/healthz
ok

$ curl --cacert ca/ca.crt https://127.0.0.1:6443/version
{
  "major": "1",
  "minor": "30",
  "gitVersion": "v1.30.2",
  "gitCommit": "39683505b630ff2121012f3c5b16215a1449d5ed",
  "gitTreeState": "clean",
  "buildDate": "2024-06-11T20:21:00Z",
  "goVersion": "go1.22.4",
  "compiler": "gc",
  "platform": "linux/amd64"
}
```

## admin
### Tools Download
```bash
[ -d kubectl ] || mkdir -p kubectl
curl -s -L "https://storage.googleapis.com/kubernetes-release/release/v${kube_ver}/bin/linux/amd64/kubectl" -o "kubectl/kubectl-v${kube_ver}"
```

### Config
```bash
sudo cp -v "kubectl/kubectl-v${kube_ver}" /usr/local/bin/kubectl
sudo chmod -v 755 /usr/local/bin/kubectl

kube_conf_file='admin/admin.kubeconfig'
kubectl config set-cluster ${CLUSTER_NAME} --certificate-authority=ca/ca.crt --embed-certs=true --server=https://${IP_MASTER}:6443 --kubeconfig=${kube_conf_file}
kubectl config set-credentials admin --client-certificate=admin/admin.crt --client-key=admin/admin.key --embed-certs=true --kubeconfig=${kube_conf_file}
kubectl config set-context default --cluster=${CLUSTER_NAME} --user=admin --kubeconfig=${kube_conf_file}
kubectl config use-context default --kubeconfig=${kube_conf_file}
[ -d ~/.kube ] || mkdir ~/.kube && cp -v ${kube_conf_file} ~/.kube/config

#  Bash Auto Completion
sudo yum -y install bash-completion
source /usr/share/bash-completion/bash_completion
kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null
source /etc/bash_completion.d/kubectl
echo 'alias k=kubectl' >> ~/.bashrc
echo 'complete -o default -F __start_kubectl k' >> ~/.bashrc
source ~/.bashrc  
```

### Verify
```bash
$ kubectl cluster-info
Kubernetes control plane is running at https://127.0.0.1:6443

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.

$ kubectl get clusterrolebindings cluster-admin -o yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  name: cluster-admin
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
### Tools Download
```bash
[ -d kubelet ] || mkdir -p kubelet
url -s -L "https://github.com/kubernetes-sigs/cri-tools/releases/download/v${crictl_ver}/crictl-v${crictl_ver}-linux-amd64.tar.gz" -o "kubelet/crictl-v${crictl_ver}-linux-amd64.tar.gz"
curl -s -L "https://github.com/opencontainers/runc/releases/download/v${runc_ver}/runc.amd64" -o "kubelet/runc.amd64-v${runc_ver}"
curl -s -L "https://github.com/containernetworking/plugins/releases/download/v${cni_ver}/cni-plugins-linux-amd64-v${cni_ver}.tgz" -o "kubelet/cni-plugins-linux-amd64-v${cni_ver}.tgz"
curl -s -L "https://github.com/containerd/containerd/releases/download/v${containerd_ver}/containerd-${containerd_ver}-linux-amd64.tar.gz" -o "kubelet/containerd-${containerd_ver}-linux-amd64.tar.gz"
curl -s -L "https://storage.googleapis.com/kubernetes-release/release/v${kube_ver}/bin/linux/amd64/kubelet" -o "kubelet/kubelet-v${kube_ver}"
```

### CNI
#### Config
```bash
cat <<EOF> kubelet/10-bridge.conf
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
          [{"subnet": "${POD_CIDR_MASTER}"}]
        ],
        "routes": [{"dst": "0.0.0.0/0"}]
    }
}
EOF

cat <<EOF> kubelet/99-loopback.conf
{
    "cniVersion": "0.4.0",
    "name": "lo",
    "type": "loopback"
}
EOF
```

#### Deployment
```bash
lsmod | grep -q br_netfilter || sudo modprobe br_netfilter

sudo mkdir -p /opt/cni/bin
sudo tar xf kubelet/cni-plugins-linux-amd64-v${cni_ver}.tgz -C /opt/cni/bin/

sudo mkdir -p /etc/cni/net.d/
sudo cp -v kubelet/10-bridge.conf /etc/cni/net.d/10-bridge.conf
sudo cp -v kubelet/99-loopback.conf /etc/cni/net.d/99-loopback.conf
```

### containerd
#### Config
```bash
cat <<EOF> kubelet/containerd-config.toml
version = 2

[plugins."io.containerd.grpc.v1.cri"]
  [plugins."io.containerd.grpc.v1.cri".containerd]
    snapshotter = "overlayfs"
    default_runtime_name = "runc"
  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
    runtime_type = "io.containerd.runc.v2"
  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
    SystemdCgroup = true
    BinaryName = "/usr/local/bin/runc-v${runc_ver}"
[plugins."io.containerd.grpc.v1.cri".cni]
  bin_dir = "/opt/cni/bin"
  conf_dir = "/etc/cni/net.d"
EOF

cat <<EOF> kubelet/containerd.service
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

# crictl config
cat <<EOF> kubelet/crictl.yaml
runtime-endpoint: unix:///var/run/containerd/containerd.sock
image-endpoint: unix:///var/run/containerd/containerd.sock
timeout: 10
debug: false
EOF
```

#### Deployment
```bash
mkdir -p kubelet/containerd
tar xf "kubelet/containerd-${containerd_ver}-linux-amd64.tar.gz" -C kubelet/containerd
sudo cp -arv kubelet/containerd/bin/* /bin/
sudo cp -v "kubelet/runc.amd64-v${runc_ver}" /usr/local/bin/runc-v${runc_ver} && sudo chmod -v 755 /usr/local/bin/runc-v${runc_ver}

sudo mkdir -p /etc/containerd/ && sudo cp kubelet/containerd-config.toml /etc/containerd/config.toml
sudo cp -v kubelet/containerd.service /etc/systemd/system/containerd.service
sudo systemctl daemon-reload
sudo systemctl enable --now containerd.service

# crictl deployment
sudo cp -v kubelet/crictl.yaml /etc/crictl.yaml
mkdir -p kubelet/crictl
tar xf "kubelet/crictl-v${crictl_ver}-linux-amd64.tar.gz" -C kubelet/crictl
sudo cp -v kubelet/crictl/crictl /usr/local/bin/crictl
```
Verify
```bash
$ sudo /usr/local/bin/crictl info
```

### kubelet
#### Config
```bash
kube_conf_file='kubelet/kubelet.kubeconfig'
kubectl config set-cluster ${CLUSTER_NAME} --certificate-authority=ca/ca.crt --embed-certs=true --server=https://${IP_MASTER}:6443 --kubeconfig=${kube_conf_file}
kubectl config set-credentials system:node:${HOSTNAME_MASTER} --client-certificate=kubelet/kubelet.crt --client-key=kubelet/kubelet.key --embed-certs=true --kubeconfig=${kube_conf_file}
kubectl config set-context default --cluster=${CLUSTER_NAME} --user=system:node:${HOSTNAME_MASTER} --kubeconfig=${kube_conf_file}
kubectl config use-context default --kubeconfig=${kube_conf_file}

cat <<EOF> kubelet/kubelet-config.yaml
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
  - "${SVC_CIDR%${SVC_CIDR##*.}}10"
podCIDR: "${POD_CIDR_MASTER}"
resolvConf: "/run/systemd/resolve/resolv.conf"
runtimeRequestTimeout: "15m"
tlsCertFile: "/var/lib/kubelet/kubelet.crt"
tlsPrivateKeyFile: "/var/lib/kubelet/kubelet.key"
containerRuntimeEndpoint: "unix:///var/run/containerd/containerd.sock"
cgroupDriver: "systemd"
EOF

cat <<EOF> kubelet/kubelet.service
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/kubernetes/kubernetes
After=containerd.service
Requires=containerd.service

[Service]
ExecStart=/usr/local/bin/kubelet-v${kube_ver} \\
  --config=/var/lib/kubelet/kubelet-config.yaml \\
  --kubeconfig=/var/lib/kubelet/kubelet.kubeconfig \\
  --register-node=true \\
  --hostname-override=${HOSTNAME_MASTER} \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```

#### Deployment
```bash
[ -d /var/lib/kubelet ] || sudo mkdir -p /var/lib/kubelet && sudo cp -v kubelet/kubelet.kubeconfig /var/lib/kubelet/kubelet.kubeconfig

sudo mkdir -p /run/systemd/resolve /var/lib/kubelet/
sudo ln -s /etc/resolv.conf /run/systemd/resolve/resolv.conf

sudo cp -v kubelet/kubelet-config.yaml /var/lib/kubelet/kubelet-config.yaml
sudo cp -v kubelet/kubelet.crt /var/lib/kubelet/kubelet.crt
sudo cp -v kubelet/kubelet.key /var/lib/kubelet/kubelet.key
sudo cp -v "kubelet/kubelet-v${kube_ver}" "/usr/local/bin/kubelet-v${kube_ver}" && sudo chmod -v 755 "/usr/local/bin/kubelet-v${kube_ver}"

sudo cp -v kubelet/kubelet.service /etc/systemd/system/kubelet.service
sudo systemctl daemon-reload
sudo systemctl enable --now kubelet.service
```

### Grant `kube-apiserver` Access to `kubelet`
Note: `user` configured in `clusterrolebinding: system:kube-apiserver` should be aligned with `CN` in `kube-apiserver` cert.
```bash
cat <<EOF> kube-apiserver_to_kubelet.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  name: system:kube-apiserver-to-kubelet
rules:
  - apiGroups:
      - ""
    resources:
      - nodes/proxy
      - nodes/stats
      - nodes/log
      - nodes/spec
      - nodes/metrics
    verbs:
      - "*"
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: system:kube-apiserver
  namespace: ""
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:kube-apiserver-to-kubelet
subjects:
  - apiGroup: rbac.authorization.k8s.io
    kind: User
    name: kube-apiserver
EOF

kubectl apply -f kube-apiserver_to_kubelet.yaml
```

### Verify
```bash
$ curl http://127.0.0.1:10248/healthz
ok

$ kubectl get nodes
NAME                              STATUS   ROLES    AGE   VERSION
ecs-matrix-k8s-cluster-master01   Ready    <none>   73s   v1.30.2

$ curl -s --cacert ca/ca.crt --cert kubelet/kubelet.crt --key kubelet/kubelet.key https://127.0.0.1:6443/api/v1/nodes | jq '.items[].metadata.name' 
"ecs-matrix-k8s-cluster-master01"

# kubectl running config 
$ kubectl proxy &

$ curl http://127.0.0.1:8001/api/v1/nodes/ecs-matrix-k8s-cluster-master01/proxy/configz | jq .
{
  "kubeletconfig": {
    "enableServer": true,
    "podLogsDir": "/var/log/pods",
    "syncFrequency": "1m0s",
    "fileCheckFrequency": "20s",
    "httpCheckFrequency": "20s",
    "address": "0.0.0.0",
    "port": 10250,
    "tlsCertFile": "/var/lib/kubelet/kubelet.crt",
    "tlsPrivateKeyFile": "/var/lib/kubelet/kubelet.key",
    "authentication": {
      "x509": {
        "clientCAFile": "/var/lib/kubernetes/ca.crt"
      },
      "webhook": {
        "enabled": true,
        "cacheTTL": "2m0s"
      },
      "anonymous": {
        "enabled": false
      }
    },
    "authorization": {
      "mode": "Webhook",
      "webhook": {
        "cacheAuthorizedTTL": "5m0s",
        "cacheUnauthorizedTTL": "30s"
      }
    },
    "registryPullQPS": 5,
    "registryBurst": 10,
    "eventRecordQPS": 50,
    "eventBurst": 100,
    "enableDebuggingHandlers": true,
    "healthzPort": 10248,
    "healthzBindAddress": "127.0.0.1",
    "oomScoreAdj": -999,
    "clusterDomain": "cluster.local",
    "clusterDNS": [
      "10.32.0.10"
    ],
    "streamingConnectionIdleTimeout": "4h0m0s",
    "nodeStatusUpdateFrequency": "10s",
    "nodeStatusReportFrequency": "5m0s",
    "nodeLeaseDurationSeconds": 40,
    "imageMinimumGCAge": "2m0s",
    "imageMaximumGCAge": "0s",
    "imageGCHighThresholdPercent": 85,
    "imageGCLowThresholdPercent": 80,
    "volumeStatsAggPeriod": "1m0s",
    "cgroupsPerQOS": true,
    "cgroupDriver": "systemd",
    "cpuManagerPolicy": "none",
    "cpuManagerReconcilePeriod": "10s",
    "memoryManagerPolicy": "None",
    "topologyManagerPolicy": "none",
    "topologyManagerScope": "container",
    "runtimeRequestTimeout": "15m0s",
    "hairpinMode": "promiscuous-bridge",
    "maxPods": 110,
    "podCIDR": "10.64.1.0/24",
    "podPidsLimit": -1,
    "resolvConf": "/run/systemd/resolve/resolv.conf",
    "cpuCFSQuota": true,
    "cpuCFSQuotaPeriod": "100ms",
    "nodeStatusMaxImages": 50,
    "maxOpenFiles": 1000000,
    "contentType": "application/vnd.kubernetes.protobuf",
    "kubeAPIQPS": 50,
    "kubeAPIBurst": 100,
    "serializeImagePulls": true,
    "evictionHard": {
      "imagefs.available": "15%",
      "imagefs.inodesFree": "5%",
      "memory.available": "100Mi",
      "nodefs.available": "10%",
      "nodefs.inodesFree": "5%"
    },
    "evictionPressureTransitionPeriod": "5m0s",
    "enableControllerAttachDetach": true,
    "makeIPTablesUtilChains": true,
    "iptablesMasqueradeBit": 14,
    "iptablesDropBit": 15,
    "failSwapOn": true,
    "memorySwap": {},
    "containerLogMaxSize": "10Mi",
    "containerLogMaxFiles": 5,
    "containerLogMaxWorkers": 1,
    "containerLogMonitorInterval": "10s",
    "configMapAndSecretChangeDetectionStrategy": "Watch",
    "enforceNodeAllocatable": [
      "pods"
    ],
    "volumePluginDir": "/usr/libexec/kubernetes/kubelet-plugins/volume/exec/",
    "logging": {
      "format": "text",
      "flushFrequency": "5s",
      "verbosity": 2,
      "options": {
        "text": {
          "infoBufferSize": "0"
        },
        "json": {
          "infoBufferSize": "0"
        }
      }
    },
    "enableSystemLogHandler": true,
    "enableSystemLogQuery": false,
    "shutdownGracePeriod": "0s",
    "shutdownGracePeriodCriticalPods": "0s",
    "enableProfilingHandler": true,
    "enableDebugFlagsHandler": true,
    "seccompDefault": false,
    "memoryThrottlingFactor": 0.9,
    "registerNode": true,
    "localStorageCapacityIsolation": true,
    "containerRuntimeEndpoint": "unix:///var/run/containerd/containerd.sock"
  }
}
```

## kube-proxy
### Tools Download
```bash
[ -d kube-proxy ] || mkdir -p kube-proxy
curl -s -L "https://storage.googleapis.com/kubernetes-release/release/v${kube_ver}/bin/linux/amd64/kube-proxy" -o kube-proxy/kube-proxy-v${kube_ver}
```

### Config
```bash
kube_conf_file='kube-proxy/kube-proxy.kubeconfig'
kubectl config set-cluster ${CLUSTER_NAME} --certificate-authority=ca/ca.crt --embed-certs=true --server=https://${IP_MASTER}:6443 --kubeconfig=${kube_conf_file}
kubectl config set-credentials system:kube-proxy --client-certificate=kube-proxy/kube-proxy.crt --client-key=kube-proxy/kube-proxy.key --embed-certs=true --kubeconfig=${kube_conf_file}
kubectl config set-context default --cluster=${CLUSTER_NAME} --user=system:kube-proxy --kubeconfig=${kube_conf_file}
kubectl config use-context default --kubeconfig=${kube_conf_file}

cat <<EOF> kube-proxy/kube-proxy-config.yaml
kind: KubeProxyConfiguration
apiVersion: kubeproxy.config.k8s.io/v1alpha1
clientConnection:
  kubeconfig: "/var/lib/kube-proxy/kube-proxy.kubeconfig"
mode: "iptables"
clusterCIDR: "${CLUSTER_CIDR}"
EOF

cat <<EOF> kube-proxy/kube-proxy.service
[Unit]
Description=Kubernetes Kube Proxy
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-proxy-v${kube_ver} \\
  --config=/var/lib/kube-proxy/kube-proxy-config.yaml \\
  --hostname-override=${HOSTNAME_MASTER}
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

cat <<EOF> kubelet/sysctl-kubernetes.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
```

### Deployment
```bash
sudo yum -y install socat conntrack ipset

sudo cp -v kubelet/sysctl-kubernetes.conf /etc/sysctl.d/kubernetes.conf
sudo sysctl --system

sudo cp -v kube-proxy/kube-proxy-v${kube_ver} /usr/local/bin/kube-proxy-v${kube_ver} && sudo chmod -v 755 /usr/local/bin/kube-proxy-v${kube_ver}

sudo mkdir -p /var/lib/kube-proxy
sudo cp -v kube-proxy/kube-proxy.kubeconfig /var/lib/kube-proxy/kube-proxy.kubeconfig

sudo cp -v kube-proxy/kube-proxy-config.yaml /var/lib/kube-proxy/kube-proxy-config.yaml
sudo cp -v kube-proxy/kube-proxy.service /etc/systemd/system/kube-proxy.service
sudo systemctl daemon-reload
sudo systemctl enable --now kube-proxy.service
```

### Verify
```bash
$ curl http://127.0.0.1:10256/healthz
{"lastUpdated": "2024-06-21 11:08:45.074765635 +0000 UTC m=+80.277574766","currentTime": "2024-06-21 11:08:45.074765635 +0000 UTC m=+80.277574766", "nodeEligible": true}

$ curl -s http://127.0.0.1:10249/metrics
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
### Tools Download
```bash
[ -d kube-scheduler ] || mkdir kube-scheduler
curl -s -L "https://storage.googleapis.com/kubernetes-release/release/v${kube_ver}/bin/linux/amd64/kube-scheduler" -o "kube-scheduler/kube-scheduler-v${kube_ver}"
```

### Config
```bash
kube_conf_file='kube-scheduler/kube-scheduler.kubeconfig'
kubectl config set-cluster ${CLUSTER_NAME} --certificate-authority=ca/ca.crt --embed-certs=true --server=https://127.0.0.1:6443 --kubeconfig=${kube_conf_file}
kubectl config set-credentials system:kube-scheduler --client-certificate=kube-scheduler/kube-scheduler.crt --client-key=kube-scheduler/kube-scheduler.key --embed-certs=true --kubeconfig=${kube_conf_file}
kubectl config set-context default --cluster=${CLUSTER_NAME} --user=system:kube-scheduler --kubeconfig=${kube_conf_file}
kubectl config use-context default --kubeconfig=${kube_conf_file}

cat <<EOF> kube-scheduler/kube-scheduler.yaml
apiVersion: kubescheduler.config.k8s.io/v1
kind: KubeSchedulerConfiguration
clientConnection:
  kubeconfig: "/var/lib/kubernetes/kube-scheduler.kubeconfig"
leaderElection:
  leaderElect: true
EOF

cat <<EOF> kube-scheduler/kube-scheduler.service
[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-scheduler-v${kube_ver} \\
    --tls-cert-file=/var/lib/kubernetes/kube-scheduler.crt \\
    --tls-private-key-file=/var/lib/kubernetes/kube-scheduler.key \\
    --config=/etc/kubernetes/config/kube-scheduler.yaml \\
    --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```

### Deployment
```bash
sudo cp -v "kube-scheduler/kube-scheduler-v${kube_ver}" "/usr/local/bin/kube-scheduler-v${kube_ver}" && sudo chmod -v 755 "/usr/local/bin/kube-scheduler-v${kube_ver}"
sudo cp -v kube-scheduler/kube-scheduler.kubeconfig /var/lib/kubernetes/kube-scheduler.kubeconfig

sudo mkdir -p /etc/kubernetes/config/
sudo cp -v kube-scheduler/kube-scheduler.yaml /etc/kubernetes/config/kube-scheduler.yaml
sudo cp -v kube-scheduler/kube-scheduler.crt /var/lib/kubernetes/kube-scheduler.crt
sudo cp -v kube-scheduler/kube-scheduler.key /var/lib/kubernetes/kube-scheduler.key

sudo cp -v kube-scheduler/kube-scheduler.service /etc/systemd/system/kube-scheduler.service
sudo systemctl daemon-reload
sudo systemctl enable --now kube-scheduler.service
```

### Verify
```bash
$ curl --cacert ca/ca.crt https://127.0.0.1:10259/healthz
ok

$ kubectl get componentstatuses scheduler
Warning: v1 ComponentStatus is deprecated in v1.19+
NAME        STATUS    MESSAGE   ERROR
scheduler   Healthy   ok
```

## kube-controller-manager
### Tools Download
```bash
[ -d kube-controller-manager ] || mkdir kube-controller-manager
curl -s -L "https://storage.googleapis.com/kubernetes-release/release/v${kube_ver}/bin/linux/amd64/kube-controller-manager" -o "kube-controller-manager/kube-controller-manager-v${kube_ver}"
```

### Config
```bash
kube_conf_file='kube-controller-manager/kube-controller-manager.kubeconfig'
kubectl config set-cluster ${CLUSTER_NAME}  --certificate-authority=ca/ca.crt --embed-certs=true --server=https://127.0.0.1:6443 --kubeconfig=${kube_conf_file}
kubectl config set-credentials system:kube-controller-manager --client-certificate=kube-controller-manager/kube-controller-manager.crt --client-key=kube-controller-manager/kube-controller-manager.key --embed-certs=true --kubeconfig=${kube_conf_file}
kubectl config set-context default --cluster=${CLUSTER_NAME} --user=system:kube-controller-manager --kubeconfig=${kube_conf_file}
kubectl config use-context default --kubeconfig=${kube_conf_file}

cat <<EOF> kube-controller-manager/kube-controller-manager.service
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-controller-manager-v${kube_ver} \\
  --bind-address=0.0.0.0 \\
  --cluster-cidr=${CLUSTER_CIDR} \\
  --cluster-name=kubernetes \\
  --cluster-signing-cert-file=/var/lib/kubernetes/ca.crt \\
  --cluster-signing-key-file=/var/lib/kubernetes/ca.key \\
  --kubeconfig=/var/lib/kubernetes/kube-controller-manager.kubeconfig \\
  --leader-elect=true \\
  --root-ca-file=/var/lib/kubernetes/ca.crt \\
  --service-account-private-key-file=/var/lib/kubernetes/kube-controller-manager.key \\
  --service-cluster-ip-range=${SVC_CIDR} \\
  --use-service-account-credentials=true \\
  --tls-cert-file=/var/lib/kubernetes/kube-controller-manager.crt \\
  --tls-private-key-file=/var/lib/kubernetes/kube-controller-manager.key \\
  --v=2
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```

### Deployment
```bash
sudo cp -v "kube-controller-manager/kube-controller-manager-v${kube_ver}" "/usr/local/bin/kube-controller-manager-v${kube_ver}" && sudo chmod -v 755 "/usr/local/bin/kube-controller-manager-v${kube_ver}"

sudo cp -v kube-controller-manager/kube-controller-manager.crt /var/lib/kubernetes/kube-controller-manager.crt
sudo cp -v kube-controller-manager/kube-controller-manager.key /var/lib/kubernetes/kube-controller-manager.key
# remove passwd from CA private key
openssl rsa -passin pass:"$CA_KEY_PASS" -in ca/ca.key | sudo tee /var/lib/kubernetes/ca.key

sudo cp -v kube-controller-manager/kube-controller-manager.kubeconfig /var/lib/kubernetes/kube-controller-manager.kubeconfig

sudo cp -v kube-controller-manager/kube-controller-manager.service /etc/systemd/system/kube-controller-manager.service
sudo systemctl daemon-reload
sudo systemctl enable --now kube-controller-manager.service
```

### Verify
```bash
$ kubectl get componentstatuses controller-manager
Warning: v1 ComponentStatus is deprecated in v1.19+
NAME                 STATUS    MESSAGE   ERROR
controller-manager   Healthy   ok

$ curl --cacert ca/ca.crt https://127.0.0.1:10257/healthz
ok
```

## `kube-dns` add-on
### Deploy
```bash
cat <<EOF> kube-dns.yaml
apiVersion: v1
kind: Service
metadata:
  name: kube-dns
  namespace: kube-system
  labels:
    k8s-app: kube-dns
    kubernetes.io/cluster-service: "true"
    addonmanager.kubernetes.io/mode: Reconcile
    kubernetes.io/name: "KubeDNS"
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
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: kube-dns
  namespace: kube-system
  labels:
    kubernetes.io/cluster-service: "true"
    addonmanager.kubernetes.io/mode: Reconcile
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: kube-dns
  namespace: kube-system
  labels:
    addonmanager.kubernetes.io/mode: EnsureExists
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kube-dns
  namespace: kube-system
  labels:
    k8s-app: kube-dns
    kubernetes.io/cluster-service: "true"
    addonmanager.kubernetes.io/mode: Reconcile
spec:
  replicas: 1
  strategy:
    rollingUpdate:
      maxSurge: 10%
      maxUnavailable: 0
  selector:
    matchLabels:
      k8s-app: kube-dns
  template:
    metadata:
      labels:
        k8s-app: kube-dns
      annotations:
        prometheus.io/port: "10054"
        prometheus.io/scrape: "true"
    spec:
      priorityClassName: system-cluster-critical
      securityContext:
        seccompProfile:
          type: RuntimeDefault
        supplementalGroups: [ 65534 ]
        fsGroup: 65534
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                  - key: k8s-app
                    operator: In
                    values: ["kube-dns"]
              topologyKey: kubernetes.io/hostname
      tolerations:
      - key: "CriticalAddonsOnly"
        operator: "Exists"
      volumes:
      - name: kube-dns-config
        configMap:
          name: kube-dns
          optional: true
      nodeSelector:
        kubernetes.io/os: linux
      containers:
      - name: kubedns
        image: registry.k8s.io/dns/k8s-dns-kube-dns:1.22.28
        resources:
          limits:
            memory: 200Mi
          requests:
            cpu: 100m
            memory: 70Mi
        livenessProbe:
          httpGet:
            path: /healthcheck/kubedns
            port: 10054
            scheme: HTTP
          initialDelaySeconds: 60
          timeoutSeconds: 5
          successThreshold: 1
          failureThreshold: 5
        readinessProbe:
          httpGet:
            path: /readiness
            port: 8081
            scheme: HTTP
          initialDelaySeconds: 3
          timeoutSeconds: 5
        args:
        - --domain=cluster.local.
        - --dns-port=10053
        - --config-dir=/kube-dns-config
        - --v=2
        env:
        - name: PROMETHEUS_PORT
          value: "10055"
        ports:
        - containerPort: 10053
          name: dns-local
          protocol: UDP
        - containerPort: 10053
          name: dns-tcp-local
          protocol: TCP
        - containerPort: 10055
          name: metrics
          protocol: TCP
        volumeMounts:
        - name: kube-dns-config
          mountPath: /kube-dns-config
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          runAsUser: 1001
          runAsGroup: 1001
      - name: dnsmasq
        image: registry.k8s.io/dns/k8s-dns-dnsmasq-nanny:1.23.1
        livenessProbe:
          httpGet:
            path: /healthcheck/dnsmasq
            port: 10054
            scheme: HTTP
          initialDelaySeconds: 60
          timeoutSeconds: 5
          successThreshold: 1
          failureThreshold: 5
        args:
        - -v=2
        - -logtostderr
        - -configDir=/etc/k8s/dns/dnsmasq-nanny
        - -restartDnsmasq=true
        - --
        - -k
        - --cache-size=1000
        - --no-negcache
        - --dns-loop-detect
        - --log-facility=-
        - --server=/cluster.local/127.0.0.1#10053
        - --server=/in-addr.arpa/127.0.0.1#10053
        - --server=/ip6.arpa/127.0.0.1#10053
        ports:
        - containerPort: 53
          name: dns
          protocol: UDP
        - containerPort: 53
          name: dns-tcp
          protocol: TCP
        resources:
          requests:
            cpu: 150m
            memory: 20Mi
        volumeMounts:
        - name: kube-dns-config
          mountPath: /etc/k8s/dns/dnsmasq-nanny
        securityContext:
          capabilities:
            drop:
              - all
            add:
              - NET_BIND_SERVICE
              - SETGID
      - name: sidecar
        image: registry.k8s.io/dns/k8s-dns-sidecar:1.23.1
        livenessProbe:
          httpGet:
            path: /metrics
            port: 10054
            scheme: HTTP
          initialDelaySeconds: 60
          timeoutSeconds: 5
          successThreshold: 1
          failureThreshold: 5
        args:
        - --v=2
        - --logtostderr
        - --probe=kubedns,127.0.0.1:10053,kubernetes.default.svc.cluster.local,5,SRV
        - --probe=dnsmasq,127.0.0.1:53,kubernetes.default.svc.cluster.local,5,SRV
        ports:
        - containerPort: 10054
          name: metrics
          protocol: TCP
        resources:
          requests:
            memory: 20Mi
            cpu: 10m
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          runAsUser: 1001
          runAsGroup: 1001
      dnsPolicy: Default  # Don't use cluster DNS.
      serviceAccountName: kube-dns
EOF

kubectl apply -f kube-dns.yaml
```

### Verify
```bash
$ k run test --image=busybox:stable -- sleep 1d

$ k exec test -- nslookup www.google.com
Server:         10.32.0.10
Address:        10.32.0.10:53

Non-authoritative answer:
Name:   www.google.com
Address: 142.250.181.36

Non-authoritative answer:
Name:   www.google.com
Address: 2a00:1450:4019:80a::2004

$ k exec test -- nslookup kubernetes.default.svc.cluster.local
Server:         10.32.0.10
Address:        10.32.0.10:53


Name:   kubernetes.default.svc.cluster.local
Address: 10.32.0.1
```

## Test
### SVC
```bash 
$ echo "Nginx HomePage" > index.html

$ kubectl create configmap nginx-index --from-file=index.html=index.html

$ cat<<EOF> nginx-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx
  name: nginx
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - image: nginx:stable-alpine
        name: nginx
        volumeMounts:
        - name: nginx-index
          mountPath: /usr/share/nginx/html/index.html
          subPath: index.html
      volumes:
      - name: nginx-index
        configMap:
          name: nginx-index
EOF

$ kubectl apply -f nginx-deployment.yaml

$ kubectl port-forward $(kubectl get pods -l app=nginx -o jsonpath='{.items[*].metadata.name}') 8080:80
Forwarding from 127.0.0.1:8080 -> 80
Forwarding from [::1]:8080 -> 80

$ curl http://127.0.0.1:8080
Nginx HomePage

$ kubectl logs $(kubectl get pods -l app=nginx -o jsonpath='{.items[*].metadata.name}')
......
127.0.0.1 - - [21/Jun/2024:12:27:42 +0000] "HEAD / HTTP/1.1" 200 0 "-" "curl/7.29.0" "-"
......

$ kubectl expose deployment nginx --port 80 --type NodePort
service/nginx exposed

$ kubectl get svc nginx
NAME    TYPE       CLUSTER-IP    EXTERNAL-IP   PORT(S)        AGE
nginx   NodePort   10.32.0.181   <none>        80:30634/TCP   40s

$ curl http://localhost:30634
Nginx HomePage

$ kubectl delete deployment nginx
deployment.apps "nginx" deleted

$ kubectl delete svc nginx
service "nginx" deleted
```

### CSR
```bash
$ openssl genrsa -out matrix.key 2048

$ openssl req -new -key matrix.key -out matrix.csr -subj "/CN=matrix" -config ca/ca.cnf -reqexts usr_cert_no_alt

$ cat <<EOF> matrix-csr.yaml
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: matrix
spec:
  request: $(cat matrix.csr | base64 -w0)
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: 86400  # one day
  usages:
  - client auth
EOF

$ kubectl apply -f matrix-csr.yaml

$ kubectl get csr

$ kubectl certificate approve matrix

$ kubectl get csr matrix -o jsonpath='{.status.certificate}'| base64 -d > matrix.crt

$ kubectl create role matrix-role --verb get --verb list --resource pods
$ kubectl create rolebinding matrix-rolebinding --role=matrix-role --user=matrix

$ kubectl auth can-i get pods --as matrix
yes

$ kubectl config set-credentials matrix --client-key=matrix.key --client-certificate=matrix.crt --embed-certs
$ kubectl config set-context matrix@ecs-matrix-k8s-cluster-all-in-one --cluster=ecs-matrix-k8s-cluster-all-in-one --user=matrix
$ kubectl config use-context matrix@ecs-matrix-k8s-cluster-all-in-one
$ kubectl get pods
NAME   READY   STATUS    RESTARTS   AGE
test   1/1     Running   0          67m

$ kubectl run test-matrix --image=nginx:stable-alpine
Error from server (Forbidden): pods is forbidden: User "matrix" cannot create resource "pods" in API group "" in the namespace "default"
```

## Extra: add worker node
### Env 
```bash
cat <<EOF>> .bashrc
export IP_WORKER01='192.168.50.79'
export HOSTNAME_WORKER01='ecs-matrix-k8s-cluster-worker01'
export POD_CIDR_WORKER01='10.64.1.0/24'
export KUBE_APISERVER_IP=${IP_MASTER}
EOF
```

### Cert
```bash
# Cert Config
cat <<EOF>> ca/ca.cnf

# For \`kubelet-worker01\`
[ usr_cert_alts_worker01 ]
basicConstraints                = CA:false
keyUsage                        = critical, digitalSignature, keyEncipherment
subjectAltName                  = @alt_names_alts_worker01

[ alt_names_alts_worker01 ]
DNS.1 = localhost
DNS.2 = ${HOSTNAME_WORKER01}
IP.1 = 127.0.0.1
IP.2 = ${IP_WORKER01}
EOF

# Private Key
openssl genrsa -out kubelet/kubelet-worker01.key 2048
# Cert Request
openssl req -new -out kubelet/kubelet-worker01.csr -key kubelet/kubelet-worker01.key -config ca/ca.cnf -subj "/C=CN/ST=BJ/L=Beijing/O=system:nodes/OU=Matrix/CN=system:node:${HOSTNAME_WORKER01}" -reqexts usr_cert_alts_worker01
# Public Cert
openssl ca -in kubelet/kubelet-worker01.csr -out kubelet/kubelet-worker01.crt -notext -config ca/ca.cnf -subj "/C=CN/ST=BJ/L=Beijing/O=system:nodes/OU=Matrix/CN=system:node:${HOSTNAME_WORKER01}" -extensions usr_cert_alts_worker01 -passin pass:"$CA_KEY_PASS" -batch
```

### CNI
```bash
lsmod | grep -q br_netfilter || sudo modprobe br_netfilter

cat <<EOF> kubelet/sysctl-kubernetes.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo cp -v kubelet/sysctl-kubernetes.conf /etc/sysctl.d/kubernetes.conf
sudo sysctl --system

sudo mkdir -p /opt/cni/bin
sudo tar xf kubelet/cni-plugins-linux-amd64-v${cni_ver}.tgz -C /opt/cni/bin/

cat <<EOF> kubelet/10-bridge-worker01.conf
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
          [{"subnet": "${POD_CIDR_WORKER01}"}]
        ],
        "routes": [{"dst": "0.0.0.0/0"}]
    }
}
EOF

cat <<EOF> kubelet-worker01/99-loopback.conf
{
    "cniVersion": "0.4.0",
    "name": "lo",
    "type": "loopback"
}
EOF

sudo mkdir -p /etc/cni/net.d/
sudo cp -v kubelet/10-bridge-worker01.conf /etc/cni/net.d/10-bridge.conf
sudo cp -v kubelet/99-loopback.conf /etc/cni/net.d/99-loopback.conf
```

### containerd
```bash
mkdir -p kubelet/containerd
tar xf "kubelet/containerd-${containerd_ver}-linux-amd64.tar.gz" -C kubelet/containerd
sudo cp -arv kubelet/containerd/bin/* /bin/
sudo cp -v "kubelet/runc.amd64-v${runc_ver}" /usr/local/bin/runc-v${runc_ver} && sudo chmod -v 755 /usr/local/bin/runc-v${runc_ver}

cat <<EOF> kubelet/containerd-config.toml
version = 2

[plugins."io.containerd.grpc.v1.cri"]
  [plugins."io.containerd.grpc.v1.cri".containerd]
    snapshotter = "overlayfs"
    default_runtime_name = "runc"
  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
    runtime_type = "io.containerd.runc.v2"
  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
    SystemdCgroup = true
    BinaryName = "/usr/local/bin/runc-v${runc_ver}"
[plugins."io.containerd.grpc.v1.cri".cni]
  bin_dir = "/opt/cni/bin"
  conf_dir = "/etc/cni/net.d"
EOF

cat <<EOF> kubelet/containerd.service
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

sudo mkdir -p /etc/containerd/ && sudo cp kubelet/containerd-config.toml /etc/containerd/config.toml
sudo cp -v kubelet/containerd.service /etc/systemd/system/containerd.service
sudo systemctl daemon-reload
sudo systemctl enable --now containerd.service

# crictl installation
cat <<EOF> kubelet/crictl.yaml
runtime-endpoint: unix:///var/run/containerd/containerd.sock
image-endpoint: unix:///var/run/containerd/containerd.sock
timeout: 10
debug: false
EOF

sudo cp -v kubelet/crictl.yaml /etc/crictl.yaml
mkdir -p kubelet/crictl
tar xf "kubelet/crictl-v${crictl_ver}-linux-amd64.tar.gz" -C kubelet/crictl
sudo cp -v kubelet/crictl/crictl /usr/local/bin/crictl
```

### kubelet
```bash
kube_conf_file='kubelet/kubelet-worker01.kubeconfig'
kubectl config set-cluster ${CLUSTER_NAME} --certificate-authority=ca/ca.crt --embed-certs=true --server=https://${KUBE_APISERVER_IP}:6443 --kubeconfig=${kube_conf_file}
kubectl config set-credentials system:node:${HOSTNAME_WORKER01} --client-certificate=kubelet/kubelet-worker01.crt --client-key=kubelet/kubelet-worker01.key --embed-certs=true --kubeconfig=${kube_conf_file}
kubectl config set-context default --cluster=${CLUSTER_NAME} --user=system:node:${HOSTNAME_WORKER01} --kubeconfig=${kube_conf_file}
kubectl config use-context default --kubeconfig=${kube_conf_file}

[ -d /var/lib/kubelet ] || sudo mkdir -p /var/lib/kubelet && sudo cp -v kubelet/kubelet-worker01.kubeconfig /var/lib/kubelet/kubelet.kubeconfig

sudo mkdir -p /run/systemd/resolve /var/lib/kubelet/
sudo ln -s /etc/resolv.conf /run/systemd/resolve/resolv.conf

cat <<EOF> kubelet/kubelet-config-worker01.yaml
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
  - "${SVC_CIDR%${SVC_CIDR##*.}}10"
podCIDR: "${POD_CIDR_WORKER01}"
resolvConf: "/run/systemd/resolve/resolv.conf"
runtimeRequestTimeout: "15m"
tlsCertFile: "/var/lib/kubelet/kubelet-worker01.crt"
tlsPrivateKeyFile: "/var/lib/kubelet/kubelet-worker01.key"
containerRuntimeEndpoint: "unix:///var/run/containerd/containerd.sock"
cgroupDriver: "systemd"
EOF

sudo mkdir -p /var/lib/kubernetes/
sudo cp -v kubelet/kubelet-config-worker01.yaml /var/lib/kubelet/kubelet-config-worker01.yaml
sudo cp -v kubelet/kubelet-worker01.crt /var/lib/kubelet/kubelet-worker01.crt
sudo cp -v kubelet/kubelet-worker01.key /var/lib/kubelet/kubelet-worker01.key
sudo cp -v ca/ca.crt /var/lib/kubernetes/ca.crt
sudo cp -v "kubelet/kubelet-v${kube_ver}" "/usr/local/bin/kubelet-v${kube_ver}" && sudo chmod -v 755 "/usr/local/bin/kubelet-v${kube_ver}"

cat <<EOF> kubelet/kubelet-worker01.service
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/kubernetes/kubernetes
After=containerd.service
Requires=containerd.service

[Service]
ExecStart=/usr/local/bin/kubelet-v${kube_ver} \\
  --config=/var/lib/kubelet/kubelet-config-worker01.yaml \\
  --kubeconfig=/var/lib/kubelet/kubelet.kubeconfig \\
  --register-node=true \\
  --hostname-override=${HOSTNAME_WORKER01} \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo cp -v kubelet/kubelet-worker01.service /etc/systemd/system/kubelet.service
sudo systemctl daemon-reload
sudo systemctl enable --now kubelet.service
```

### kube-proxy
#### Config
All other config files / cert files are same as master node.  
```bash
cat <<EOF> kube-proxy/kube-proxy-worker01.service
[Unit]
Description=Kubernetes Kube Proxy
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-proxy-v${kube_ver} \\
  --config=/var/lib/kube-proxy/kube-proxy-config.yaml \\
  --hostname-override=${HOSTNAME_WORKER01}
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```

#### Deployment
```bash
sudo yum -y install socat conntrack ipset
sudo cp -v kube-proxy/kube-proxy-v${kube_ver} /usr/local/bin/kube-proxy-v${kube_ver} && sudo chmod -v 755 /usr/local/bin/kube-proxy-v${kube_ver}

sudo mkdir -p /var/lib/kube-proxy
sudo cp -v kube-proxy/kube-proxy.kubeconfig /var/lib/kube-proxy/kube-proxy.kubeconfig

sudo cp -v kube-proxy/kube-proxy-config.yaml /var/lib/kube-proxy/kube-proxy-config.yaml
sudo cp -v kube-proxy/kube-proxy-worker01.service /etc/systemd/system/kube-proxy.service
sudo systemctl daemon-reload
sudo systemctl enable --now kube-proxy.service
```

### static route
```bash
# add route on master node 
sudo route add -net ${POD_CIDR_WORKER01} gateway ${IP_WORKER01}
# add route on worker node 
sudo route add -net ${POD_CIDR_MASTER} gateway ${IP_MASTER}
```

### Verify
```bash
$ kubectl get nodes
NAME                              STATUS   ROLES    AGE     VERSION
ecs-matrix-k8s-cluster-master     Ready    <none>   56m     v1.30.2
ecs-matrix-k8s-cluster-worker01   Ready    <none>   4m58s   v1.30.2
```

{% include links.html %}