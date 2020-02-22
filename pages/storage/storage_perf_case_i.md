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
| SSD | INTEL SSDSC2KB960G8 ([D3-S4510 Series](https://ark.intel.com/content/www/us/en/ark/products/series/134791/intel-ssd-d3-s4510-series.html)) | INTEL SSDSC2KG96 ([D3-S4610 Series](https://ark.intel.com/content/www/us/en/ark/products/134917/intel-ssd-d3-s4610-series-960gb-2-5in-sata-6gb-s-3d2-tlc.html)) & INTEL SSDSC2KG96 ([DC S4600 Series](https://ark.intel.com/content/www/us/en/ark/products/120518/intel-ssd-dc-s4600-series-960gb-2-5in-sata-6gb-s-3d1-tlc.html)) | INTEL SSDSC2KG96 (D3-S4610 Series) & INTEL SSDSC2KG96 (DC S4600 Series)
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

### Result (finish time in Seconds)

| | Host1 | Host2 | Host3 
| :------------- | :------------- | :------------ | :-------------
| Avg Time to Write 20GB | 20.6339 Seconds | 13.8235 Seconds | 12.4453 Seconds
{: .table-bordered }
[iostat/iotop collected](images/storage/storage_perf_case_i/sequetial_write.tar.bz2)

### Conclusion
`XFS` is better on throughput test scenario than `EXT4`


## Random Write

### Env Info

| | Host1 | Host2 (CPU on `ondemand`) | Host2 (CPU on `performance`) | Host3 
| :------------- | :------------- | :------------ | :------------ | :------------
| CPU | Xeon(R) CPU E5-2650 v4 @ 2.20GHz (48 Cores) | Xeon(R) CPU E5-2650 v4 @ 2.20GHz (48 Cores) | Xeon(R) CPU E5-2650 v4 @ 2.20GHz (48 Cores) | Xeon(R) E-2288G CPU @ 3.70GHz (16 Cores)
| CPU Governor | performance | ondemand | performance | powersave
| Memory | DDR4 2400 MHz 32G x 4 | DDR4 2400 MHz 32G x 4 | DDR4 2400 MHz 32G x 4 | DDR4 2666 MHz 32G x 4
| Raid Controller | AVAGO MegaRAID SAS 9361-8i (1G Cache) | HPE Smart Array P440 (4G Cache) | HPE Smart Array P440 (4G Cache) | AVAGO MegaRAID SAS 9361-4i (1G Cache)
| SSD | INTEL SSDSC2KG96 (D3-S4610 Series) | INTEL SSDSC2KG96 (D3-S4610 Series) | INTEL SSDSC2KG96 (D3-S4610 Series) | INTEL SSDSC2KB960G8 (D3-S4510 Series)
| RAID Info | 4 SSDs → RAID0 | 4 SSDs → RAID0 | 4 SSDs → RAID0 | 4 SSDs → RAID0 
| Filesystem | EXT4 | EXT4 | EXT4 | EXT4
| Mountpoint | /export | /export | /export | /var
{: .table-bordered }

### How-to Run Test
#### FIO Profile
```
$ cat randw.fio
[global]
        ioengine=libaio
        invalidate=1
        direct=1
        iodepth=20
        ramp_time=30
        random_generator=tausworthe64
        randrepeat=0
        verify=0
        verify_fatal=0
        runtime=300
        exitall=1

[rand]
        filename=/export/test.img
        size=10G
        rw=randwrite
        bs=${blocksize}
        numjobs=${threads}
```

#### Test Script
```
$ cat test.sh
#! /bin/bash

blocksize=$1
threads=$2
sn=$3

export blocksize
export threads
output_dir="${blocksize}-${threads}t/"

if [ ! -d ${output_dir} ]; then
        mkdir ${output_dir}
fi

echo "====== ${blocksize}/${threads} Test Round ${sn} started ======"

echo 'cfq' > /sys/block/sdb/queue/scheduler
cat /sys/block/sdb/queue/scheduler

for i in `seq 0 47`; do echo performance > /sys/devices/system/cpu/cpu${i}/cpufreq/scaling_governor; done
performance_count=$(for i in `seq 0 47`; do cat /sys/devices/system/cpu/cpu${i}/cpufreq/scaling_governor; done | grep 'performance'  | wc -l)

if [ ${performance_count} -ne 48 ]; then
        echo "something wrong with cpu setting"
else
        echo "48 cpus are running on performance state"
fi

iotop -b -o -t -d1 > ${output_dir}/iotop.$sn &
iostat -tkx 1 sdb > ${output_dir}/iostat.$sn &

echo 3 > /proc/sys/vm/drop_caches
rm -vf /export/test.img
fio randw.fio > ${output_dir}/fio.result.$sn

echo "====== ${blocksize}/${threads} Test Round ${sn} ended ======"

unset blocksize
unset threads

for pid_iotop in `ps aux | awk '/iotop/{print $2}'`; do
        kill -9 ${pid_iotop} > /dev/null 2>&1
done

for pid_iostat in `ps aux | awk '/iostat/{print $2}'`; do
        kill -9 ${pid_iostat} > /dev/null 2>&1
done
```

#### Test CMD with 32threads
```
$ for j in `seq 1 3`; do for i in {4,8,16}; do ./test.sh ${i}k 32 $
```

#### CMD to collect result
```
$ $ for i in `seq 1 3`; do  grep -R '^\s*write' 4k-32t/fio.result.$i | awk -F',' '{print $3}' | awk -F'=' 'BEGIN{SUM=0}{SUM+=$2}END{print SUM}'; done | awk 'BEGIN{SUM=0}{SUM+=$0}END{print SUM/NR}'
```

### Result (in IOPS with different blocksize)

| | 4k | 8k | 16k
| :------------- | :------------- | :------------ | :-------------
| Host1 | 159703 | 124112 | 58969.3
| Host2 (CPU on `ondemand`) | 34277.9 | 55004.9 | 50909.5 
| Host2 (CPU on `performance`) | 178449 | 112723 | 54417
| Host3 | 142179 | 115600 | 36361.3
{: .table-bordered }
[fio/iostat/iotop collected](images/storage/storage_perf_case_i/random_write.tar.bz2)

### Conclusion
CPU freqency is crucial for io performance.

## Random Write (io_scheduler / filesystem)

### Env info

| | Host | Host | Host 
| :------------- | :------------- | :------------ | :------------ | :------------
| CPU | Xeon(R) CPU E5-2650 v4 @ 2.20GHz (48 Cores) | Xeon(R) CPU E5-2650 v4 @ 2.20GHz (48 Cores) | Xeon(R) CPU E5-2650 v4 @ 2.20GHz (48 Cores) 
| CPU Governor | performance | performance | performance
| Memory | DDR4 2400 MHz 32G x 4 | DDR4 2400 MHz 32G x 4 | DDR4 2400 MHz 32G x 4
| Raid Controller | HPE Smart Array P440 (4G Cache) | HPE Smart Array P440 (4G Cache) | HPE Smart Array P440 (4G Cache)
| SSD | INTEL SSDSC2KG96 (D3-S4610 Series) | INTEL SSDSC2KG96 (D3-S4610 Series) | INTEL SSDSC2KG96 (D3-S4610 Series)
| RAID Info | 6 SSDs → RAID0 | 6 SSDs → RAID0 | 6 SSDs → RAID0
| Filesystem | EXT4 | EXT4 | XFS
| IO Scheduler | noop | cfq | noop
| Mountpoint | /export | /export | /export
{: .table-bordered }

### Result (iops with 32threads)

| | 4k | 8k | 16k
| :------------- | :------------- | :------------ | :-------------
| Host(ext4/cfq) | 44711.7 | 40876.7 | 34597.7
| Host(ext4/noop) | 186779 | 155757 | 111132
| Host(xfs/noop) | 138856 | 145067 | 111602
{: .table-bordered }
[fio/iostat/iotop collected](images/storage/storage_perf_case_i/random_write1.tar.bz2)

### Conclusion
- For SSD, io scheduler `noop` is much better than `cfq`, which is default io scheduler in CentOS7/RHEL7.
- `XFS` performance on random write is poor than `EXT4`, especialy io blocksize is smaller.

{% include links.html %}
