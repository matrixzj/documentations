---
title: Crictl Containerd Docker
tags: [contianer]
keywords: crictl,containerd,docker
last_updated: Jun 12, 2022
summary: "cli memo for ctictl/containerd/docker"
sidebar: mydoc_sidebar
permalink: container_crictl_containerd_docker.html
folder: Container
---

# Crictl / Containerd / Docker
======

| Functions | Crictl CLI | Containerd CLI | Docker CLI |
| :------ | :------ | :------ | :------ |
| Image List | crictl images | ctr image ls | docker images |
| Image Export |  | ctr image export app.tar weiyigeek.top/app:1.2.0 | docker save -o app.tar app:1.2.0 |
| Image Import | | ctr image import app.tar | docker load -i app.tar |
| Image Pull | crictl pull redis:latest | ctr -n k8s.io images pull docker.io/library/redis:latest | docker pull redis:latest |
| Image Push | crictl push redis:latest | ctr -n k8s.io images push docker.io/library/redis:latest | docker push redis:latest |
| Image Tag Update | | ctr -n k8s.io images tag docker.io/library/redis:latest weiyigeek.top/redis:latest | docker tag redis:latest weiyigeek.top/redis:latest |
| Image Delete | crictl rmi redis:latest | ctr -n k8s.io images rm docker.io/library/redis:latest | docker rmi redis:latest |
| Container Create | | ctr -n k8s.io container create docker.io/library/redis:latest redis | docker create --name redis redis:latest |
| Container Create Run | | ctr -n k8s.io run -d --env name=WeiyiGeek weiyigeek.top/app:1.2.0 app | docker run -d --name app weiyigeek.top/app:1.2.0 |
| Container List | crictl ps | ctr -n k8s.io container list | docker ps |
| Container Start| crictl start | ctr -n k8s.io task start app | docker start app |
| Container Pause |  | ctr -n k8s.io task pause app | docker pause app |
| Container Stop | crictl stop | ctr -n k8s.io task kill app | docker stop app |
| Container Delete | crictl rm | ctr -n k8s.io container rm [-f] app | docker rm [-f] app |
| Container Detail Inspect | crictl inspect app | ctr -n k8s.io c info app |docker inspect app |
| Container Attach | crictl attach | ctr -n k8s.io task attach app | docker attach app |
| Run cmd inside Container | crictl exec -it app sh | ctr -n k8s.io task exec -t exec-id pid app sh | docker exec -it app sh |
| Container Status | crictl stats | ctr -n k8s.io task metric app | docker top app |
| Container Log | crictl logs | ctr -n k8s.io event | docker logs --tail 50 app |
| Copy files from Container | | 1 挂载本地磁盘/tmp/mymount到app容器：ctr -n k8s.io snapshot mounts /tmp/mymount app <br/> 2 从本地/tmp/mymount目录复制文件：cp /tmp/mymount/data ~/data <br/> 3 卸载/tmp/mymount目录：umount /tmp/mymount | docker cp |


{% include links.html %}
