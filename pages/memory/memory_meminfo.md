---
title: Meminfo
tags: [memory, info]
keywords: segfaults
last_updated: Juue 17, 2019
summary: "Linux Memory Info"
sidebar: mydoc_sidebar
permalink: memory_meminfo.html
folder: memory
---

## /proc/meminfo, sar
=====

### /proc/meminfo

```bash
$ cat /proc/meminfo
MemTotal:       65796288 kB
MemFree:        49429344 kB
MemAvailable:   64166652 kB
Buffers:          402372 kB
Cached:         13905632 kB
SwapCached:            0 kB
Active:         11509652 kB
Inactive:        3313652 kB
Active(anon):     550152 kB
Inactive(anon):    49960 kB
Active(file):   10959500 kB
Inactive(file):  3263692 kB
Unevictable:           0 kB
Mlocked:               0 kB
SwapTotal:       8388604 kB
SwapFree:        8388604 kB
Dirty:               108 kB
Writeback:             0 kB
AnonPages:        515128 kB
Mapped:            91320 kB
Shmem:             84820 kB
Slab:            1082376 kB
SReclaimable:    1005096 kB
SUnreclaim:        77280 kB
KernelStack:        6752 kB
PageTables:        12276 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:    41286748 kB
Committed_AS:    1221184 kB
VmallocTotal:   34359738367 kB
VmallocUsed:      190608 kB
VmallocChunk:   34325450672 kB
HardwareCorrupted:     0 kB
AnonHugePages:    251904 kB
HugePages_Total:       0
HugePages_Free:        0
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:       2048 kB
DirectMap4k:      237756 kB
DirectMap2M:    16529408 kB
DirectMap1G:    50331648 kB
```

* **Committed_AS** 
An estimate of how much RAM you would need to make a 99.99% guarantee that there never is OOM (out of memory) for this workload. Normally the kernel will overcommit memory. That means, say you do a 1GB malloc, nothing happens, really. Only when you start USING that malloc memory you will get real memory on demand, and just as much as you use. So you sort of take a mortgage and hope the bank doesn't go bust. Other cases might include when you mmap a file that's shared only when you write to it and you get a private copy of that data. While it normally is shared between processes. The Committed_AS is a guesstimate of how much RAM/swap you would need worst-case.


{% include links.html %}
# Segmentation Faults(Segfaults)
