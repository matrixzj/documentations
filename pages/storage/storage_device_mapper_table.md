---
title: Device Mapper Table
tags: [storage]
keywords: device mapper, lvm
last_updated: Juue 18, 2019
summary: "Inteprete Device Mapper Table"
sidebar: mydoc_sidebar
permalink: storage_device_mapper_table.html
folder: storage
---

Device Mapper Table
======

### General
```
start length mapping [mapping_parameters...]
```  
In the first line of a Device Mapper table, the **start** parameter must equal 0. The **start + length** parameters on one line must equal the start on the next line. Which mapping parameters are specified in a line of the mapping table depends on which mapping type is specified on the line.  
Sizes in the Device Mapper are always specified in sectors (512 bytes).  
When a device is specified as a mapping parameter in the Device Mapper, it can be referenced by the device name in the filesystem (for example, /dev/hda) or by the major and minor numbers in the format **major:minor**. The major:minor format is preferred because it avoids pathname lookups.

The following subsections describe the format of the following mappings:  
* [linear](#linear)
* [striped](#striped)
* [mirror](#mirrored)
* [snapshot & snapshot-origin]()

### linear
```
start length linear device offset
```
* start  
   starting block in virtual device  
* length  
   length of this segment  
* device  
   block device, referenced by the device name in the filesystem or by the major and minor numbers in the format major:minor  
* offset  
   starting offset of the mapping on the device  

#### linear example I:
```
0 4186112 linear 8:2 2048
```  
* 0  
   starting block in virtual device  
* 4186112  
   length of this segment (in sectors), 4186112/2/1024 = 2044 Mb = 511 * 4Mb
   ```
   $ sudo lvdisplay /dev/vg0/swap | grep LE
     Current LE             511
   ```
* 8:2  
   major:minor numbers of underneath device
* 2048  
   offset of underneath device

### striped
```
start length striped #stripes chunk_size device1 offset1 ... deviceN offsetN
```
* start  
   starting block in virtual device
* length  
   length of this segment
* #stripes  
   number of stripes for the virtual device
* chunk_size  
   number of sectors written to each stripe before switching to the next; must be power of 2 at least as big as the kernel page size
* device  
   block device, referenced by the device name in the filesystem or by the major and minor numbers in the format major:minor.
* offset  
   starting offset of the mapping on the device

#### striped example I:
```
0 2097152 striped 2 128 252:16 2048 252:32 2048
```
* 0  
   starting block in virtual device
* length  
   length of this segment
* striped 2 128 
   stripe across 2 devices with chunk size of 128 sectors
* 252:16 2048 252:32 2048  
   major:minor numbers and offset for devices constituting striped device

### mirrored
```
mirror log_type #logargs logarg1 ... logargN #devs device1 offset1 ... deviceN offsetN <#features> <feature_1>...<feature_N>
```  
LVM maintains a small log which it uses to keep track of which regions are in sync with the mirror or mirrors. 

#### log_type  
For **log_type** there are 4 values with different arguments:  
* core  
   The mirror is local and the mirror log is kept in core memory. This log type takes 1 - 3 arguments:
   ```
   logdevice regionsize [[no]sync] [block_on_error]
   ```
* disk  
   The mirror is local and the mirror log is kept on disk. This log type takes 2 - 4 arguments:
   ```
   logdevice regionsize [[no]sync] [block_on_error]
   ```
* clustered_core  
   The mirror is clustered and the mirror log is kept in core memory. This log type takes 2 - 4 arguments:
   ```
   logdevice regionsize UUID [[no]sync] [block_on_error]
   ```
* clustered_disk  
   The mirror is clustered and the mirror log is kept on disk. This log type takes 3 - 5 arguments:
   ```
   logdevice regionsize UUID [[no]sync] [block_on_error]  
   ```

   **regionsize** argument specifies the size of these regions. It must be power of 1 and at least of a kernel page (for Intel x86/x64 processors, this is 4 KiB (8 sectors) This is the granularity in which the mirror is kept to update. Its a tradeoff between increased metadata and wasted I/O. LVM uses a value of 512 KiB (1024 sectors).  
   **UUID** argument is a unique identifier associated with the mirror log device so that the log state can be maintained throughout the cluster.  
   **[no]sync** argument can be used to specify the mirror as "in-sync" or "out-of-sync".  
   **block_on_error** argument is used to tell the mirror to respond to errors rather than ignoring them.  

#### log_args
   number of log arguments that will be specified in the mapping  
* **logargs**  
   the log arguments for the mirror; the number of log arguments provided is specified by the #log-args parameter and the valid log arguments are determined by the log_typeparameter.  
* **#devs**  
   the number of legs in the mirror; a device and an offset is specified for each leg  
* **device**  
   block device for each mirror leg, referenced by the device name in the filesystem or by the major and minor numbers in the format major:minor. A block device and offset is specified for each mirror leg, as indicated by the #devs parameter.  
* **offset**  
   starting offset of the mapping on the device. A block device and offset is specified for each mirror leg, as indicated by the #devs parameter.  

#### feature
there is only 1 feature:  
* **handle_errors**  
   causes the mirror to respond to an error. Default is to ignore all errors. LVM enables this feature.

#### mirror example I: 
shows a mirror mapping target for a clustered mirror with a mirror log kept on disk.
```
0 52428800 mirror clustered_disk 4 253:2 1024 UUID block_on_error 3 253:3 0 253:4 0 253:5 0
```
* 0  
   starting block in virtual device  
* 52428800  
   length of this segment (in sectors)  
* mirror clustered_disk1  
   mirror target with a log type specifying that mirror is clustered and the mirror log is maintained on disk  
* 4  
   4 mirror log arguments will follow  
* 253:2  
   major:minor numbers of log device  
* 1024  
   region size the mirror log uses to keep track of what is in sync  
* UUID  
   UUID of mirror log device to maintain log information throughout a cluster  
* block_on_error  
   mirror should respond to errors  
* 3  
   number of legs in mirror  
* 253:3 0 253:4 0 253:5 0  
   major:minor numbers and offset for devices constituting each leg of mirror

#### mirror example II:
```
0 2252800 mirror disk 2 253:2 1024 2 253:3 0 253:4 0 1 handle_errors
```
* 0  
   starting block in virtual device  
* 2252800  
   length of this segment (in sectors), 2252800/2/1024/4 = 1100 Mb = 275 * 4Mb  
   ```
   # lvdisplay /dev/vg1/test  | grep LE  
   Current LE             275  
   ```
* mirror disk   
   mirror is local and the mirror log is kept on disk  
* 2  
   2 mirror log arguments will follow  
* 253:2  
   major:minor numbers of log device  
* 1024   
   region size the mirror log uses to keep track of what is in sync  
* 2  
   number of legs in mirror  
* 253:3 0 253:4 0  
   major:minor numbers and offset for devices constituting each leg of mirror  
* 1 handle_errors  
   causes the mirror to respond to an error.  

### snapshot and snapshot-origin
When you create the first LVM snapshot of a volume, four Device Mapper devices are used:
* A device with a **linear** mapping containing the original mapping table of the source volume.
* A device with a **linear** mapping used as the copy-on-write (COW) device for the source volume; for each write, the original data is saved in the COW device of each snapshot to keep its visible content unchanged (until the COW device fills up).
* A device with a **snapshot** mapping combining #1 and #2, which is the visible snapshot volume.  
   ```
   start length snapshot origin COW-device P|N chunksize
   ```
   * start  
      starting block in virtual device
   * length  
      length of this segment
   * origin  
      base volume of snapshot
   * COW-device  
      device on which changed chunks of data are stored
   * P|N  
      P (Persistent) or N (Not persistent); indicates whether the snapshot will survive after reboot. For transient snapshots (N) less metadata must be saved on disk; they can be kept in memory by the kernel.
   * chunksize  
      size in sectors of changed chunks of data that will be stored on the COW device
* The "original" volume (which uses the device number used by the original source volume), whose table is replaced by a "**snapshot-origin**" mapping from device #1.i
   ```
   start length snapshot-origin origin
   ```
   * start  
      starting block in virtual device
   * length  
      length of this segment
   * origin  
      base volume of snapshot

{% include links.html %}
