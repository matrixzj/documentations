---
title: docker cli memo
tags: [container]
keywords: docker, cli
last_updated: Jul 8, 2022
summary: "docker cli memo"
sidebar: mydoc_sidebar
permalink: docker_cli_memo.html
folder: Container
---

# Docker CLI Memo
======

## Run

### Publish or export port with `--expose` / `-p`
`-p [host_ip_addr:]host_port:container_port/protocol`

```bash
docker run --name clickcounter -p 8085:5000 --links redis kodekloud/click-counter
```

It was implemented by `iptables`
```bash
$ iptables -t nat -L POSTROUTING -n   
Chain POSTROUTING (policy ACCEPT)
target     prot opt source               destination         
MASQUERADE  all  --  172.12.0.0/24        0.0.0.0/0           
DOCKER_POSTROUTING  all  --  0.0.0.0/0            172.25.0.1          
MASQUERADE  tcp  --  172.12.0.3           172.12.0.3           tcp dpt:5000

$ iptables -t nat -L DOCKER -n
Chain DOCKER (2 references)
target     prot opt source               destination         
RETURN     all  --  0.0.0.0/0            0.0.0.0/0           
DNAT       tcp  --  0.0.0.0/0            0.0.0.0/0            tcp dpt:8085 to:172.12.0.3:5000
```

### Communication across links `link`
`--link <name or id>:alias`

## docker-compose
```bash
$ cat docker-compose.yml 
redis:
  image: redis:alpine
clickcounter:
  image: kodekloud/click-counter
  ports:
  - 8085:5000
  links:
  - redis
```

## volumes
`--mount type=bind,source=/opt/data,target=/var/lib/mysql`
`type` The type of the mount, which can be `bind`, `volume`, or `tmpfs`. 
`source`/`src` The source of mount
`target`/`dst` The path where the file or directory is mounted in the container

```bash
docker-compose -f docker-compose.yml up
```

{% include links.html %}
