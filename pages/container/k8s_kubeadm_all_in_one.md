---
title: Kubernetes All-in-One Deployment with kubeadm 
tags: [container]
keywords: kubernetes, k8s, kubeadm
last_updated: Dec 14 2022
summary: "All in one deployment for Kubernetes cluster with kubeadm"
sidebar: mydoc_sidebar
permalink: k8s_kubeadm_all_in_one.html
folder: Container
---

# Kubernetes All-in-One Deployment with kubeadm
=====

## Env
```bash
# hostnamectl set-hostname ecs-matrix-k8s-cluster-3

# echo "$(ifconfig eth0 | awk '/inet /{print $2}')" "$(hostname)" >> /etc/hosts

# yum install -y yum-utils device-mapper-persistent-data lvm2 wget
```

## System Preparation
```bash
$ cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

$ sudo modprobe overlay

$ sudo modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
$ cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
$ sudo sysctl --system

$ sudo apt-get update
$ sudo apt-get install -y apt-transport-https ca-certificates curl
```

## Install `kubernetes` related packages
```bash
# add google gpg key
$ sudo mkdir /etc/apt/keyrings/

$ curl -o kubernetes-archive-keyring.gpg 'https://packages.cloud.google.com/apt/doc/apt-key.gpg'
$ sudo cp kubernetes-archive-keyring.gpg /etc/apt/keyrings/

# add google k8s packages list
$ echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
$ sudo apt-get update

# List available versions
$ sudo apt-cache madison kubeadm kubelet kubectl

# Install specific version
$ sudo apt-get install kubeadm=1.25.0-00 kubelet=1.25.0-00 kubectl=1.25.0-00
```

## Option 1: Install `docker` as `CRI`, `weave-net` add-on as CNI
### `golang` installation
```bash
# curl -o installer_linux https://storage.googleapis.com/golang/getgo/installer_linux

# chmod 755 installer_linux

# ./installer_linux
Welcome to the Go installer!
Downloading Go version go1.18.3 to /root/.go
This may take a bit of time...
Downloaded!
Setting up GOPATH
GOPATH has been set up!

One more thing! Run `source /root/.bash_profile` to persist the
new environment variables to your current session, or open a
new shell prompt.

# source /root/.bash_profile
```

### Docker 
#### Installation
```bash
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

$ echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

$ sudo apt-get update

$ sudo apt-get install docker-ce

$ sudo systemctl enable --now docker
```

#### Verify
```bash
$ docker -v
Docker version 20.10.21, build baeda1f
```

### cri-dockerd
Kubernetes is deprecating Docker as a container runtime after v1.20.
[Don't Panic: Kubernetes and Docker](https://kubernetes.io/blog/2020/12/02/dont-panic-kubernetes-and-docker/)

#### Installation
```bash
$ git clone https://github.com/Mirantis/cri-dockerd

$ cd cri-dockerd

$ mkdir bin

$ go get && go build ${CRI_DOCKERD_LDFLAGS} -o cri-dockerd

$ sudo install -o root -g root -m 0755 cri-dockerd /usr/local/bin/cri-dockerd

$ sudo cp -v packaging/systemd/*  /etc/systemd/system
‘packaging/systemd/cri-docker.service’ -> ‘/etc/systemd/system/cri-docker.service’
‘packaging/systemd/cri-docker.socket’ -> ‘/etc/systemd/system/cri-docker.socket’

$ sudo sed -E -i 's#/usr/bin/cri-dockerd#//usr/local/bin/cri-dockerd#' /etc/systemd/system/cri-docker.service

$ sudo systemctl daemon-reload

$ sudo systemctl enable --now cri-docker

$ systemctl status cri-docker
● cri-docker.service - CRI Interface for Docker Application Container Engine
   Loaded: loaded (/etc/systemd/system/cri-docker.service; enabled; vendor preset: enabled)
   Active: active (running) since Tue 2022-12-13 17:07:23 UTC; 14s ago
     Docs: https://docs.mirantis.com
 Main PID: 18681 (cri-dockerd)
    Tasks: 8
   CGroup: /system.slice/cri-docker.service
           └─18681 //usr/local/bin/cri-dockerd --container-runtime-endpoint fd://
```

### Kubernetes Deployment
```bash
$ sudo kubeadm init --service-cidr 10.32.0.0/24 --cri-socket unix:///var/run/cri-dockerd.sock
```

### CNI addon `weave-net`
```bash
$ kubectl get nodes
NAME                       STATUS     ROLES           AGE   VERSION
ecs-matrix-k8s-cluster-1   NotReady   control-plane   40s   v1.25.0

$ wget https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml 

$ cp weave-daemonset-k8s.yaml weave-daemonset-k8s.yaml.orig

$ diff -Nru weave-daemonset-k8s.yaml weave-daemonset-k8s.yaml.orig
--- weave-daemonset-k8s.yaml    2022-12-13 15:52:54.884875133 +0000
+++ weave-daemonset-k8s.yaml.orig       2022-12-13 15:34:43.611501501 +0000
@@ -144,8 +144,6 @@
               command:
                 - /home/weave/launch.sh
               env:
-                - name: IPALLOC_RANGE
-                  value: 10.64.1.0/24
                 - name: INIT_CONTAINER
                   value: "true"
                 - name: HOSTNAME

$ kubectl apply -f weave-daemonset-k8s.yaml

$ kubectl get nodes
NAME                       STATUS   ROLES           AGE   VERSION
ecs-matrix-k8s-cluster-1   Ready    control-plane   26m   v1.25.0
```

## Option 2: Install `containerd` as `CRI`/`CNI`
### CNI Network
```bash
$ wget https://github.com/containernetworking/plugins/releases/download/v1.1.1/cni-plugins-linux-amd64-v1.1.1.tgz

$ sudo mkdir /opt/cni/bin -p

$ sudo tar xvf cni-plugins-linux-amd64-v1.1.1.tgz -C /opt/cni/bin/
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

$ sudo mkdir -p /etc/cni/net.d/

$ POD_CIDR='10.64.1.0/24'

$ cat <<EOF | sudo tee /etc/cni/net.d/10-bridge.conf
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
         
$ cat <<EOF | sudo tee /etc/cni/net.d/99-loopback.conf
{
    "cniVersion": "0.4.0",
    "name": "lo",
    "type": "loopback"
}
EOF
```

### CRI
```bash
$ wget https://github.com/containerd/containerd/releases/download/v1.6.6/containerd-1.6.6-linux-amd64.tar.gz https://github.com/opencontainers/runc/releases/download/v1.1.3/runc.amd64

$ mkdir -p containerd

$ tar xvf containerd-1.6.6-linux-amd64.tar.gz -C containerd
bin/
bin/containerd
bin/containerd-shim
bin/containerd-shim-runc-v2
bin/containerd-shim-runc-v1
bin/ctr

$ sudo cp -arv containerd/bin/* /bin/
‘containerd/bin/containerd’ -> ‘/bin/containerd’
‘containerd/bin/containerd-shim’ -> ‘/bin/containerd-shim’
‘containerd/bin/containerd-shim-runc-v1’ -> ‘/bin/containerd-shim-runc-v1’
‘containerd/bin/containerd-shim-runc-v2’ -> ‘/bin/containerd-shim-runc-v2’
‘containerd/bin/ctr’ -> ‘/bin/ctr’

$ sudo cp runc.amd64 /usr/local/bin/runc

$ sudo chmod 755 /usr/local/bin/runc

$ sudo mkdir -p /etc/containerd/

$ cat <<EOF | sudo tee /etc/containerd/config.toml
[plugins]
  [plugins.cri.containerd]
    snapshotter = "overlayfs"
    [plugins.cri.containerd.default_runtime]
      runtime_type = "io.containerd.runtime.v1.linux"
      runtime_engine = "/usr/local/bin/runc"
      runtime_root = ""
EOF

$ cat <<EOF | sudo tee /etc/systemd/system/containerd.service
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

$ sudo systemctl daemon-reload

$ sudo systemctl enable --now containerd.service
```

### Kubernetes Deployment
```bash
$ sudo kubeadm init --service-cidr 10.32.0.0/24
```

## Option3: Install `containerd` as CRI, `weave-net` add-on as CNI
### Install `containerd`
```bash
sudo apt-get install containerd
```

### Kubernetes Deployment
```bash
$ sudo kubeadm init --service-cidr 10.32.0.0/24
```

### CNI addon `weave-net`
```bash
$ kubectl get nodes
NAME                       STATUS     ROLES           AGE   VERSION
ecs-matrix-k8s-cluster-1   NotReady   control-plane   40s   v1.25.0

$ wget https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml 

$ cp weave-daemonset-k8s.yaml weave-daemonset-k8s.yaml.orig

$ diff -Nru weave-daemonset-k8s.yaml weave-daemonset-k8s.yaml.orig
--- weave-daemonset-k8s.yaml    2022-12-13 15:52:54.884875133 +0000
+++ weave-daemonset-k8s.yaml.orig       2022-12-13 15:34:43.611501501 +0000
@@ -144,8 +144,6 @@
               command:
                 - /home/weave/launch.sh
               env:
-                - name: IPALLOC_RANGE
-                  value: 10.64.1.0/24
                 - name: INIT_CONTAINER
                   value: "true"
                 - name: HOSTNAME

$ kubectl apply -f weave-daemonset-k8s.yaml

$ kubectl get nodes
NAME                       STATUS   ROLES           AGE   VERSION
ecs-matrix-k8s-cluster-1   Ready    control-plane   26m   v1.25.0
```

## Kubernetes bash auto-completion  
```bash
$ sudo apt-get install bash-completion

$ sudo source /usr/share/bash-completion/bash_completion

$ cat <<EOF >>.bashrc
source <(kubectl completion bash)
alias k=kubectl
complete -o default -F __start_kubectl k
EOF

$ source ~/.bashrc
```

## (Optional) Remove master node taints  
```bash
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
```

## Decode token info 
```bash
$ k -n kube-system exec  weave-net-bv2b9  -c weave -- sh -c 'cat /var/run/secrets/kubernetes.io/serviceaccount/token' | jq -R 'split(".") | select(length > 0) | .[0], .[1] | @base64d | fromjson'
{
  "alg": "RS256",
  "kid": "Sw_lrOlnDDEjGw5A7kjnqvNiUirGqMROuR6ZIKA4edo"
}
{
  "aud": [
    "https://kubernetes.default.svc.cluster.local"
  ],
  "exp": 1711725869,
  "iat": 1680189869,
  "iss": "https://kubernetes.default.svc.cluster.local",
  "kubernetes.io": {
    "namespace": "kube-system",
    "pod": {
      "name": "weave-net-bv2b9",
      "uid": "bf8a1f9c-8434-4733-856f-a177caad41a4"
    },
    "serviceaccount": {
      "name": "weave-net",
      "uid": "cd709bc3-d226-4532-a5ec-97dd6f1e64c3"
    },
    "warnafter": 1680193476
  },
  "nbf": 1680189869,
  "sub": "system:serviceaccount:kube-system:weave-net"
}
```

## Test
As there is some `taints` configured for `nodes`, `tolerations` need to be applied for pods in order to be scheduled on this node.
```bash
# kubectl run busybox --image=busybox:latest --overrides='{"spec": {"tolerations": [{"effect": "NoSchedule","key": "node-role.kubernetes.io/master","operator": "Exists"},{"effect": "NoSchedule","key": "node-role.kubernetes.io/control-plane","operator": "Exists"}]}}' --command -- sleep 3600

# kubectl get pods
NAME                    READY   STATUS    RESTARTS   AGE
busybox                 1/1     Running   0          5s

# kubectl exec -ti busybox -- nslookup kubernetes
Server:         10.96.0.10
Address:        10.96.0.10:53

Name:   kubernetes.default.svc.cluster.local
Address: 10.96.0.1
```

{% include links.html %}