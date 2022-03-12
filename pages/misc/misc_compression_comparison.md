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

# Linux compress tools comparison
=====

## Env Info

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

## compress time

Source file is a 5000000000 bytes plain text file. 

|compress level|gzip|xz|bzip2
| :-------------: | -------------: | ------------: | ------------:
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

## compress size/ratio

### Size

|compress level|gzip|xz|bzip2
| :-------------: | -------------: | ------------: | ------------:
|0|N/A      |63670816|N/A
|1|201092010|58834544|106072672
|2|200646561|744536  |96441267
|3|200477270|743736  |93326000
|4|184356695|751064  |94263729
|5|176677138|751160  |95644321
|6|144287114|743828  |96292423
|7|143231977|743828  |95357949
|8|135962314|743828  |95836483
|9|135962314|743828  |95118532
{: .table-bordered }

### Ratio

|compress level|gzip|xz|bzip2
| :-------------: | -------------: | ------------: | ------------:
|0|     |1.27%|
|1|4.02%|1.18%|2.12%
|2|4.01%|0.01%|1.93%
|3|4.01%|0.01%|1.87%
|4|3.69%|0.02%|1.89%
|5|3.53%|0.02%|1.91%
|6|2.89%|0.01%|1.93%
|7|2.86%|0.01%|1.91%
|8|2.72%|0.01%|1.92%
|9|2.72%|0.01%|1.90%
{: .table-bordered }


{% include links.html %}
