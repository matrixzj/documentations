---
title: Compression Comparison 
tags: [misc, compression]
keywords: linux, compress, gzip, xz, bzip2
last_updated: March 17, 2020
summary: "Linux compression tools comparison"
sidebar: mydoc_sidebar
permalink: misc_compression_comparison.html
folder: Misc
---

## Linux compress tools comparison
=====

### Env Info

|Item | Info
| :------------- | :-------------
| CPU | Xeon(R) CPU E5-2670 v3 @ 2.30GHz
| Memory | 128G (8 x 16G DDR4 2133)
| Kernel | 3.10.0-1062.el7.x86_64
| Raid Controller | HPE P440ar 
| Disks | RAID 1 (2 SAS 15000 RPM Disks)
| gzip info | gzip-1.5-10.el7.x86_64
| xz info | xz-5.2.2-1.el7.x86_64
| bzip2 info | bzip2-1.0.6-13.el7.x86_64
{: .table-bordered }

### compress time

|compress level|gzip|xz|bzip2
| :------------- | :------------- | :------------ | :------------
|0|N/A    |56.308s |N/A
|1|37.588s|63.303s |510.959s
|2|36.521s|46.526s |584.670s
|3|39.755s|50.543s |610.025s
|4|46.224s|161.461s|680.018s
|5|46.437s|300.757s|667.932s
|6|72.982s|791.539s|698.389s
|7|69.909s|795.291s|718.921s
|8|62.739s|793.804s|733.866s
|9|61.819s|795.516s|746.284s
{: .table-bordered }



























{% include links.html %}
