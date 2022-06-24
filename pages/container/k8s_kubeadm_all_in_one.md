---
title: Kubernetes All-in-One Deployment with kubeadm 
tags: [container]
keywords: kubernetes, k8s, kubeadm
last_updated: Jun 18, 2022
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

# yum install -y yum-utils device-mapper-persistent-data lvm2
```



## Option 1: Install `docker` as `CRI`/`CNI`
### Docker 
#### Installation
```bash
# yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# yum install –y epel-release

# yum install –y docker-ce

# systemctl enable --now docker
```

#### Verify
```bash
# docker -v
Docker version 20.10.17, build 100c701

# docker info
Client:
 Context:    default
 Debug Mode: false
 Plugins:
  app: Docker App (Docker Inc., v0.9.1-beta3)
  buildx: Docker Buildx (Docker Inc., v0.8.2-docker)
  scan: Docker Scan (Docker Inc., v0.17.0)

Server:
 Containers: 0
  Running: 0
  Paused: 0
  Stopped: 0
 Images: 0
 Server Version: 20.10.17
 Storage Driver: overlay2
  Backing Filesystem: xfs
  Supports d_type: true
  Native Overlay Diff: true
  userxattr: false
 Logging Driver: json-file
 Cgroup Driver: cgroupfs
 Cgroup Version: 1
 Plugins:
  Volume: local
  Network: bridge host ipvlan macvlan null overlay
  Log: awslogs fluentd gcplogs gelf journald json-file local logentries splunk syslog
 Swarm: inactive
 Runtimes: io.containerd.runc.v2 io.containerd.runtime.v1.linux runc
 Default Runtime: runc
 Init Binary: docker-init
 containerd version: 10c12954828e7c7c9b6e0ea9b0c02b01407d3ae1
 runc version: v1.1.2-0-ga916309
 init version: de40ad0
 Security Options:
  seccomp
   Profile: default
 Kernel Version: 3.10.0-957.27.2.el7.x86_64
 Operating System: CentOS Linux 7 (Core)
 OSType: linux
 Architecture: x86_64
 CPUs: 2
 Total Memory: 3.7GiB
 Name: ecs-matrix-k8s-cluster-3
 ID: MAZJ:OWUX:VUPV:IPBY:6T3W:6GO7:4CI5:QRUF:JVCS:HBYH:2Q5K:KMWC
 Docker Root Dir: /var/lib/docker
 Debug Mode: false
 Registry: https://index.docker.io/v1/
 Labels:
 Experimental: false
 Insecure Registries:
  127.0.0.0/8
 Live Restore Enabled: false
```


### cri-dockerd
Kubernetes is deprecating Docker as a container runtime after v1.20.
[Don't Panic: Kubernetes and Docker](https://kubernetes.io/blog/2020/12/02/dont-panic-kubernetes-and-docker/)

#### Installation
```bash
# git clone https://github.com/Mirantis/cri-dockerd

# cd cri-dockerd

# mkdir bin

# go get && go build ${CRI_DOCKERD_LDFLAGS} -o cri-dockerd

# install -o root -g root -m 0755 bin/cri-dockerd /usr/local/bin/cri-dockerd

# cp -v packaging/systemd/*  /etc/systemd/system
‘packaging/systemd/cri-docker.service’ -> ‘/etc/systemd/system/cri-docker.service’
‘packaging/systemd/cri-docker.socket’ -> ‘/etc/systemd/system/cri-docker.socket’

# sed -E -i 's#/usr/bin/cri-dockerd#//usr/local/bin/cri-dockerd#' /etc/systemd/system/cri-docker.service

# systemctl daemon-reload

# systemctl enable --now cri-docker

# systemctl status  cri-docker
● cri-docker.service - CRI Interface for Docker Application Container Engine
   Loaded: loaded (/etc/systemd/system/cri-docker.service; enabled; vendor preset: disabled)
   Active: active (running) since Sat 2022-06-18 09:38:30 UTC; 6s ago
     Docs: https://docs.mirantis.com
 Main PID: 18585 (cri-dockerd)
    Tasks: 7
   Memory: 16.8M
   CGroup: /system.slice/cri-docker.service
           └─18585 //usr/local/bin/cri-dockerd --container-runtime-endpoint fd:// --network-plugin=

Jun 18 09:38:30 ecs-matrix-k8s-cluster-3 cri-dockerd[18585]: time="2022-06-18T09:38:30Z" level=info msg="Hairpin mode is set to none"
Jun 18 09:38:30 ecs-matrix-k8s-cluster-3 cri-dockerd[18585]: time="2022-06-18T09:38:30Z" level=info msg="The binary conntrack is not installed, ...eanup."
Jun 18 09:38:30 ecs-matrix-k8s-cluster-3 cri-dockerd[18585]: time="2022-06-18T09:38:30Z" level=info msg="The binary conntrack is not installed, ...eanup."
Jun 18 09:38:30 ecs-matrix-k8s-cluster-3 cri-dockerd[18585]: time="2022-06-18T09:38:30Z" level=info msg="Docker cri networking managed by networ.../no-op"
Jun 18 09:38:30 ecs-matrix-k8s-cluster-3 cri-dockerd[18585]: time="2022-06-18T09:38:30Z" level=info msg="Docker Info: &{ID:MAZJ:OWUX:VUPV:IPBY:6...ve Over
Jun 18 09:38:30 ecs-matrix-k8s-cluster-3 cri-dockerd[18585]: time="2022-06-18T09:38:30Z" level=info msg="Setting cgroupDriver cgroupfs"
Jun 18 09:38:30 ecs-matrix-k8s-cluster-3 systemd[1]: Started CRI Interface for Docker Application Container Engine.
Jun 18 09:38:30 ecs-matrix-k8s-cluster-3 cri-dockerd[18585]: time="2022-06-18T09:38:30Z" level=info msg="Docker cri received runtime config &Run...r:,},}"
Jun 18 09:38:30 ecs-matrix-k8s-cluster-3 cri-dockerd[18585]: time="2022-06-18T09:38:30Z" level=info msg="Starting the GRPC backend for the Docke...rface."
Jun 18 09:38:30 ecs-matrix-k8s-cluster-3 cri-dockerd[18585]: time="2022-06-18T09:38:30Z" level=info msg="Start cri-dockerd grpc backend"
Hint: Some lines were ellipsized, use -l to show in full.
```

### Kubernetes Deployment 
```bash
# cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

# yum -y install kubelet kubeadm kubectl

# kubeadm init --ignore-preflight-errors all --cri-socket unix:///var/run/cri-dockerd.sock
[init] Using Kubernetes version: v1.24.2
[preflight] Running pre-flight checks
        [WARNING Service-Kubelet]: kubelet service is not enabled, please run 'systemctl enable kubelet.service'
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
[certs] Using certificateDir folder "/etc/kubernetes/pki"
[certs] Generating "ca" certificate and key
[certs] Generating "apiserver" certificate and key
[certs] apiserver serving cert is signed for DNS names [ecs-matrix-k8s-cluster-3 kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 172.16.1.89]
[certs] Generating "apiserver-kubelet-client" certificate and key
[certs] Generating "front-proxy-ca" certificate and key
[certs] Generating "front-proxy-client" certificate and key
[certs] Generating "etcd/ca" certificate and key
[certs] Generating "etcd/server" certificate and key
[certs] etcd/server serving cert is signed for DNS names [ecs-matrix-k8s-cluster-3 localhost] and IPs [172.16.1.89 127.0.0.1 ::1]
[certs] Generating "etcd/peer" certificate and key
[certs] etcd/peer serving cert is signed for DNS names [ecs-matrix-k8s-cluster-3 localhost] and IPs [172.16.1.89 127.0.0.1 ::1]
[certs] Generating "etcd/healthcheck-client" certificate and key
[certs] Generating "apiserver-etcd-client" certificate and key
[certs] Generating "sa" key and public key
[kubeconfig] Using kubeconfig folder "/etc/kubernetes"
[kubeconfig] Writing "admin.conf" kubeconfig file
[kubeconfig] Writing "kubelet.conf" kubeconfig file
[kubeconfig] Writing "controller-manager.conf" kubeconfig file
[kubeconfig] Writing "scheduler.conf" kubeconfig file
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Starting the kubelet
[control-plane] Using manifest folder "/etc/kubernetes/manifests"
[control-plane] Creating static Pod manifest for "kube-apiserver"
[control-plane] Creating static Pod manifest for "kube-controller-manager"
[control-plane] Creating static Pod manifest for "kube-scheduler"
[etcd] Creating static Pod manifest for local etcd in "/etc/kubernetes/manifests"
[wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests". This can take up to 4m0s
[apiclient] All control plane components are healthy after 12.502412 seconds
[upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[kubelet] Creating a ConfigMap "kubelet-config" in namespace kube-system with the configuration for the kubelets in the cluster
[upload-certs] Skipping phase. Please see --upload-certs
[mark-control-plane] Marking the node ecs-matrix-k8s-cluster-3 as control-plane by adding the labels: [node-role.kubernetes.io/control-plane node.kubernetes.io/exclude-from-external-load-balancers]
[mark-control-plane] Marking the node ecs-matrix-k8s-cluster-3 as control-plane by adding the taints [node-role.kubernetes.io/master:NoSchedule node-role.kubernetes.io/control-plane:NoSchedule]
[bootstrap-token] Using token: 0ag8cm.xljiqneqb3oin11d
[bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
[bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to get nodes
[bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstrap-token] Configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstrap-token] Configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
[bootstrap-token] Creating the "cluster-info" ConfigMap in the "kube-public" namespace
[kubelet-finalize] Updating "/etc/kubernetes/kubelet.conf" to point to a rotatable kubelet client certificate and key
[addons] Applied essential addon: CoreDNS
[addons] Applied essential addon: kube-proxy

Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 172.16.1.89:6443 --token 0ag8cm.xljiqneqb3oin11d \
        --discovery-token-ca-cert-hash sha256:c7c5dbf90af9e1adf5c5e3421506451348f1ba26191ccfb16089f6fff552804f
```


## Option 2: Install `containerd` as `CRI`/`CNI`
### CNI Network
```bash
# wget https://github.com/containernetworking/plugins/releases/download/v1.1.1/cni-plugins-linux-amd64-v1.1.1.tgz

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

### CRI
```bash
# wget https://github.com/containerd/containerd/releases/download/v1.6.6/containerd-1.6.6-linux-amd64.tar.gz https://github.com/opencontainers/runc/releases/download/v1.1.3/runc.amd64

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

### Kubernetes Deployment
```bash
# cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

# yum -y install kubelet kubeadm kubectl

# kubeadm init --ignore-preflight-errors all
```

## Verify
```bash
# export KUBECONFIG=/etc/kubernetes/admin.conf

# kubectl get nodes
NAME                       STATUS   ROLES           AGE   VERSION
ecs-matrix-k8s-cluster-3   Ready    control-plane   47s   v1.24.2
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