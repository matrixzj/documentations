---
title: IO Performance
tags: [storage]
keywords: io, iostat, iotop, blktrace 
last_updated: Feb 21, 2020
summary: "IO Performance Notes"
sidebar: mydoc_sidebar
permalink: storage_io_perf.html
folder: storage
---

IO Performance
======

### Linux IO Stack

#### Overview  
[![Linux IO Stack](images/storage/Linux-storage-stack-diagram_v4.10.png)](https://www.thomas-krenn.com/en/wiki/Linux_Storage_Stack_Diagram)

#### Nutshell  
![Linux IO Nutshell](images/storage/io.png)

NOTE: The difference Between RHEL5 and Later Release:
In RHEL 5 and previous, IO was merged by individual paths after device-mapper-multipath allocated it to underneath paths.
```bash
Time: 02:42:15 AM
avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.75    0.00   24.47   12.36    0.00   62.42

Device:         rrqm/s    wrqm/s   r/s       w/s    rkB/s     wkB/s avgrq-sz avgqu-sz   await  svctm  %util
sda               0.00      0.00  0.00      0.00     0.00      0.00     0.00     0.00    0.00   0.00   0.00
sda1              0.00      0.00  0.00      0.00     0.00      0.00     0.00     0.00    0.00   0.00   0.00
sdb               0.00 134838.61  0.00   1081.19     0.00 552047.52  1021.19   105.60   99.01   0.92  99.21
sdb1              0.00 134839.60  0.00   1081.19     0.00 552047.52  1021.19   105.60   99.01   0.92  99.21
dm-2              0.00      0.00  0.00 135906.93     0.00 543627.72     8.00 13423.23   99.65   0.01  99.50
dm-3              0.00      0.00  0.00 135907.92     0.00 543631.68     8.00 13386.22   99.65   0.01  99.31
```

From RHEL6, "request-based device-mapper" was adopted by device-mapper-multipath. So io merge is happened in device-mapper-multipath before sending them to underneath paths.

```bash
12/25/2019 03:17:34 AM
avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.56    0.00   25.17    4.34    0.00   69.93

Device:         rrqm/s    wrqm/s  r/s       w/s rkB/s     wkB/s avgrq-sz  avgqu-sz  await r_await w_await svctm  %util
sdb               0.00      0.00 0.00      0.00  0.00      0.00     0.00      0.00   0.00    0.00    0.00  0.00   0.00
sda               0.00      0.00 0.00    156.00  0.00 566732.00  7265.79     34.56 220.37    0.00  220.37  6.41 100.00
dm-0              0.00 113133.00 0.00    164.00  0.00 566732.00  6911.37    150.71 846.07    0.00  846.07  6.10 100.00
dm-1              0.00      0.00 0.00 113817.00  0.00 702732.00    12.35 111791.51 896.90    0.00  896.90  0.01 100.10
```
{: .font-size: 6pt }

### Linux IO information collecting tools
#### iostat
##### Usage
```
# iostat -xkt 1 <dev_name> [-p ]
```
-x    display extended statistics  
-k    use KByte instead of sector as unit  
-t    show time  
-p    display partitions in RHEL6. In RHEL5, statistics on partitions are displayed by default, exclusive with -x  

##### Output Example
```
# iostat -tkx 1
Linux 3.10.0-514.el7.x86_64 (rhel7-test.dev.fwmrm.net)  12/12/2019      _x86_64_        (8 CPU)

12/12/2019 06:06:58 AM
avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           1.11    0.00    0.42    0.28    0.00   98.19

Device:         rrqm/s   wrqm/s     r/s    w/s        rkB/s     wkB/s a   vgrq-sz   avgqu-sz   await r_await w_await  svctm  %util
vda               0.04    23.85    7.11   52.27   442.51  5702.99   206.97     0.84      14.22  0.47   16.09     0.28   1.64
```


{% include links.html %}
