---
title: IO Performance Case I
tags: [storage]
keywords: io, iostat, iotop, fio, cpu, io_scheduler, xfs, ext4
last_updated: Feb 21, 2020
summary: "IO Performance Case I"
sidebar: mydoc_sidebar
permalink: storage_perf_case_i.html
folder: storage
---

IO Performance Case I
======

## Sequetial Write

### Env Info
| | Host1 | Host2 | Host3 
| :------------- | :------------- | :------------ | :-------------
| CPU |	Xeon(R) E-2288G CPU @ 3.70GHz (16 Cores) | Xeon(R) CPU E5-2650 v4 @ 2.20GHz (48 Cores) | Xeon(R) CPU E5-2650 v4 @ 2.20GHz (48 Cores)
| Memory | DDR4 2666 MHz 32G x 4 | DDR4 2400 MHz 32G x 4 | DDR4 2400 MHz 32G x 4
| Raid Controller |  AVAGO MegaRAID SAS 9361-4i (1G Cache) | HPE Smart Array P440 (4G Cache) | HPE Smart Array P440 (4G Cache)
| SSD | INTEL SSDSC2KB960G8 (D3-S4510 Series) | INTEL SSDSC2KG96 (D3-S4610 Series) & INTEL SSDSC2KG96 (DC S4600 Series) | INTEL SSDSC2KG96 (D3-S4610 Series) & INTEL SSDSC2KG96 (DC S4600 Series)
| RAID Info | 4 SSDs → RAID0 | 6 SSDs → RAID5 | 6 SSDs → RAID0
| Filesystem | EXT4 | XFS | XFS
| Mountpoint | /var | /var | /var
{: .table-bordered }

### Test Script
```
#! /bin/bash
 
sn=$1
 
iotop -b -o -t -d1 > iotop.$sn &
iostat -tkx 1 sda > iostat.$sn &
 
echo 3 > /proc/sys/vm/drop_caches
( time dd if=/dev/zero of=/var/tmp/test.img bs=1M count=20000 oflag=direct ) |& tee iooutput.$sn
rm -vf /var/tmp/test.img
 
kill -9 $(ps aux | awk '/iotop/{print $2}' | head -1)
kill -9 $(ps aux | awk '/iostat/{print $2}' | head -1)
```

### Result
| | Host1 | Host2 | Host3 
| :------------- | :------------- | :------------ | :-------------
| Avg Time to Write 20GB | 20.6339 Seconds | 13.8235 Seconds | 12.4453 Seconds
{: .table-bordered }



{% include links.html %}
