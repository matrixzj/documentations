---
title: Identify whether a Process running inside Container
tags: [container]
keywords: container, docker, process, cgroup
last_updated: Jun 18, 2022
summary: "identify a process running inside container"
sidebar: mydoc_sidebar
permalink: container_identify_process_inside_container.html
folder: Container
---

# Identify whether a Process running inside Container
======


## cgroup
```bash
# ps aux  | grep coredns
root      7065  0.0  0.0 112812   972 pts/0    S+   08:49   0:00 grep --color=auto coredns
root     10790  0.2  0.6 747268 26452 ?        Ssl  Jun14  10:15 /coredns -conf /etc/coredns/Corefile

# cat /proc/10790/cgroup
11:pids:/kubepods/burstable/pod44d5a51b-3e5c-4ae1-808f-6e8cfc86b69d/7b2a2f9bebf5e7a652539c4ce746d343cdfb93edbd4065acdf06c46bfb2b4b40
10:cpuacct,cpu:/kubepods/burstable/pod44d5a51b-3e5c-4ae1-808f-6e8cfc86b69d/7b2a2f9bebf5e7a652539c4ce746d343cdfb93edbd4065acdf06c46bfb2b4b40
9:blkio:/kubepods/burstable/pod44d5a51b-3e5c-4ae1-808f-6e8cfc86b69d/7b2a2f9bebf5e7a652539c4ce746d343cdfb93edbd4065acdf06c46bfb2b4b40
8:memory:/kubepods/burstable/pod44d5a51b-3e5c-4ae1-808f-6e8cfc86b69d/7b2a2f9bebf5e7a652539c4ce746d343cdfb93edbd4065acdf06c46bfb2b4b40
7:hugetlb:/kubepods/burstable/pod44d5a51b-3e5c-4ae1-808f-6e8cfc86b69d/7b2a2f9bebf5e7a652539c4ce746d343cdfb93edbd4065acdf06c46bfb2b4b40
6:devices:/kubepods/burstable/pod44d5a51b-3e5c-4ae1-808f-6e8cfc86b69d/7b2a2f9bebf5e7a652539c4ce746d343cdfb93edbd4065acdf06c46bfb2b4b40
5:freezer:/kubepods/burstable/pod44d5a51b-3e5c-4ae1-808f-6e8cfc86b69d/7b2a2f9bebf5e7a652539c4ce746d343cdfb93edbd4065acdf06c46bfb2b4b40
4:cpuset:/kubepods/burstable/pod44d5a51b-3e5c-4ae1-808f-6e8cfc86b69d/7b2a2f9bebf5e7a652539c4ce746d343cdfb93edbd4065acdf06c46bfb2b4b40
3:net_prio,net_cls:/kubepods/burstable/pod44d5a51b-3e5c-4ae1-808f-6e8cfc86b69d/7b2a2f9bebf5e7a652539c4ce746d343cdfb93edbd4065acdf06c46bfb2b4b40
2:perf_event:/kubepods/burstable/pod44d5a51b-3e5c-4ae1-808f-6e8cfc86b69d/7b2a2f9bebf5e7a652539c4ce746d343cdfb93edbd4065acdf06c46bfb2b4b40
1:name=systemd:/kubepods/burstable/pod44d5a51b-3e5c-4ae1-808f-6e8cfc86b69d/7b2a2f9bebf5e7a652539c4ce746d343cdfb93edbd4065acdf06c46bfb2b4b40
```
If `docker` / `kubepods` were shown in `cgroup` result, that means that this process is running iside `container`

```bash
# cat /proc/1/cgroup
11:pids:/
10:cpuacct,cpu:/
9:blkio:/
8:memory:/
7:hugetlb:/
6:devices:/
5:freezer:/
4:cpuset:/
3:net_prio,net_cls:/
2:perf_event:/
1:name=systemd:/
```

## namespace
```bash
# ls -al /proc/10790/ns/
total 0
dr-x--x--x 2 root root 0 Jun 18 08:50 .
dr-xr-xr-x 9 root root 0 Jun 14 19:18 ..
lrwxrwxrwx 1 root root 0 Jun 18 08:59 ipc -> ipc:[4026532274]
lrwxrwxrwx 1 root root 0 Jun 18 08:59 mnt -> mnt:[4026532276]
lrwxrwxrwx 1 root root 0 Jun 18 08:59 net -> net:[4026532194]
lrwxrwxrwx 1 root root 0 Jun 18 08:59 pid -> pid:[4026532277]
lrwxrwxrwx 1 root root 0 Jun 18 08:59 user -> user:[4026531837]
lrwxrwxrwx 1 root root 0 Jun 18 08:59 uts -> uts:[4026532273]
```

```bash
# ls -al /proc/1/ns/
total 0
dr-x--x--x 2 root root 0 Jun 12 17:37 .
dr-xr-xr-x 9 root root 0 Jun 10 19:24 ..
lrwxrwxrwx 1 root root 0 Jun 18 08:55 ipc -> ipc:[4026531839]
lrwxrwxrwx 1 root root 0 Jun 18 08:55 mnt -> mnt:[4026531840]
lrwxrwxrwx 1 root root 0 Jun 18 08:55 net -> net:[4026531956]
lrwxrwxrwx 1 root root 0 Jun 12 17:37 pid -> pid:[4026531836]
lrwxrwxrwx 1 root root 0 Jun 18 08:55 user -> user:[4026531837]
lrwxrwxrwx 1 root root 0 Jun 18 08:55 uts -> uts:[4026531838]
```
`namespace` for a process running inside `container` will NOT be same as `systemd`(`1`) process.

{% include links.html %}
