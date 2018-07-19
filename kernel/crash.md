---
title: Crash Utilities
author: Matrix Zou
layout: post
tags: [ kernel ]
---

Crash Utilities
=====

This repository is intended to contain several utilities written to help work
with crash [0] for vmcore analysis.

[0] https://people.redhat.com/anderson/crash_whitepaper/

dm-target debugging
===================

Debugging dm-targets can be a non-trivial task. Here are some tools to help.

dm-target persistent names
===========================

Note that dm device numbers, ie, dm-13, are not persistent across reboots.
This does not mean that they cannot be, this is very system specific.
Persistent dm-names can be kept accross boots if DM_PERSISTENT_DEV_FLAG is
passed to the DM_DEV_CREATE_CMD, in this case the dm core code would
instantiate dm devices with DM_ANY_MINOR which means " give me the next
available minor number". This sequence can be seen in dm-ioctl.c:dev_create
function.

Currently DM_PERSISTENT_DEV_FLAG is not explicitly used on lvm2, userspace
tools set it only if the minor is set on the dm task created, for instance:

	lvcreate or lvchange --persistent y --major major --minor minor

Note that even if none of this is used a system *can* boot with the same
dm-target names ! So best is to just verify the dm-target and respective mount
point yourselves. How to do this is explained below.

Inspecting dm-target pending IO
===============================

```bash
crash> dev -d
MAJOR GENDISK            NAME       REQUEST_QUEUE      TOTAL ASYNC  SYNC   DRV
    8 ffff883ffdb09400   sda        ffff881ffa739a70       0     0     0     0
   11 ffff881ffdc71400   sr0        ffff881ff9c99a70       0     0     0     0
    8 ffff881ff3101800   sdb        ffff881ffa76d820       0     0     0     0
    8 ffff881ff3103400   sdc        ffff881ffa7208d0       0     0     0     0
    8 ffff887ffde47c00   sdd        ffff881ffa76e0f0       0     0     0     0
    8 ffff881ff3105400   sde        ffff881ff9c511a0       0     0     0     0
    8 ffff887ffde40800   sdf        ffff881ffa76e9c0       0     0     0     0
    8 ffff881ff3107800   sdg        ffff881ff9c51a70       0     0     0     0
    8 ffff881ffb95c800   sdh        ffff881ffa76f290       0     0     0     0
    8 ffff881ff3102c00   sdi        ffff881ffa7211a0       0     0     0     0
    8 ffff883ffc679400   sdj        ffff881ffa721a70       0     0     0     0
    8 ffff881ffa7e5000   sdk        ffff881ff9c52340       0     0     0     0
    8 ffff881ff3102000   sdl        ffff881ff9c52c10       0     0     0     0
    8 ffff881ffb95f000   sdm        ffff881ffa73f290       0     0     0     0
    8 ffff881ffb959400   sdn        ffff881ffa722340       0     0     0     0
    8 ffff881ff3100800   sdo        ffff881ffa722c10       0     0     0     0
    8 ffff881ff31c3400   sdp        ffff881ffa7af290       0     0     0     0
   65 ffff881ff3220800   sdq        ffff881ffa723db0       0     0     0     0
   65 ffff880034c32c00   sdr        ffff881ffa724680       0     0     0     0
   65 ffff881ff31c2c00   sds        ffff881ff9c53db0       0     0     0     0
   65 ffff881ff3222c00   sdt        ffff881ffa7ae9c0       0     0     0     0
   65 ffff881ff31c4000   sdu        ffff881ffa724f50       0     0     0     0
   65 ffff881ff32c8400   sdv        ffff881ffa7ae0f0       0     0     0     0
   65 ffff881ff32cbc00   sdw        ffff881ffa7ad820       0     0     0     0
   65 ffff880034c35800   sdx        ffff881ffa725820       0     0     0     0
   65 ffff881ff32ce400   sdy        ffff881ff9c54680       0     0     0     0
   65 ffff881ff3225c00   sdz        ffff881ffa7acf50       0     0     0     0
   65 ffff881ff32cec00   sdaa       ffff881ffa7260f0       0     0     0     0
   65 ffff881ff32cb000   sdab       ffff881ffa7ac680       0     0     0     0
   65 ffff881ff3227c00   sdac       ffff881ffa7abdb0       0     0     0     0
  253 ffff881ff9d3e400   dm-0       ffff881ff9c969c0       0     0     0     0
  253 ffff881ff9d3f800   dm-1       ffff881ff9c960f0       0     0     0     0
  253 ffff883ffd5d1000   dm-2       ffff887ffcfd8000       0     0     0     0
  253 ffff8840d2fd5c00   dm-3       ffff885ffdca8000       0     0     0     0
  253 ffff8840d2fd2c00   dm-4       ffff885ffdca88d0       0     0     0     0
  253 ffff8840d2fd3800   dm-5       ffff885ffdca91a0       0     0     0     0
  253 ffff8840d2fd0800   dm-6       ffff885ffdca9a70       0     0     0     0
  253 ffff885ffa6b0800   dm-7       ffff885ffdcaa340       0     0     0     0
  253 ffff885ffa6b1400   dm-8       ffff885ffdcaac10       0     0     0     0
  253 ffff885ffa6b2000   dm-9       ffff885ffdcab4e0       0     0     0     0
  253 ffff885ffa6b2c00   dm-10      ffff885ffdcabdb0       0     0     0     0
  253 ffff885ffa6b3800   dm-11      ffff885ffdcac680       0     0     0     0
  253 ffff885ffa6b4400   dm-12      ffff885ffdcacf50       0     0     0     0
  253 ffff885ffa6b5000   dm-13      ffff885ffdcad820       0     0     0     0
  253 ffff885ffa6b5c00   dm-14      ffff885ffdcae0f0       0     0     0     0
  253 ffff885ffa6b6800   dm-15      ffff885ffdcae9c0       0     0     0     0
  253 ffff885ffa6b7400   dm-16      ffff885ffdcaf290       0     0     0     0
  253 ffff885ffdc94800   dm-17      ffff887fef158000       0     0     0     0
  253 ffff885ffdc4bc00   dm-18      ffff887ff76e0000       0     0     0     0
  253 ffff885ffdc93800   dm-19      ffff887fef1588d0       0     0     0     0
  253 ffff885ffdc4d400   dm-20      ffff887ff76e08d0       0     0     0     0
  253 ffff885ffdc93000   dm-21      ffff887fef1591a0       0     0     0     0
  253 ffff885ffdc4ec00   dm-22      ffff887ff76e11a0       0     0     0     0
  253 ffff885ffdc92400   dm-23      ffff887fef159a70       0     0     0     0
  253 ffff885ffdc4b800   dm-24      ffff887ff76e1a70       0     0     0     0
  253 ffff885ffdc91c00   dm-25      ffff887fef15a340       0     0     0     0
  253 ffff885ffdc4b400   dm-26      ffff887ff76e2340       0     0     0     0
  253 ffff887ffd5db800   dm-27      ffff887ff6fd0000       0     0     0     0
  253 ffff887ffd5dc000   dm-28      ffff887ff6fd08d0       0     0     0     0
  253 ffff887ffd5dc800   dm-29      ffff887ff6fd11a0       0     0     0     0
  253 ffff887ffd5dd000   dm-30      ffff887ff6fd1a70       0     0     0     0
  253 ffff887ffd5dd800   dm-31      ffff887ff6fd2340       0     0     0     0
  201 ffff881ffde5ac00   dmpconfig  ffff885ff0f98000       0     0     0     0
  201 ffff881fd9cec800   VxDMP2     ffff881ffa7aac10       0     0     0     0
  201 ffff881fd9ced000   VxDMP3     ffff881ffa7aa340       0     0     0     0
  201 ffff881fd9ceb000   VxDMP4     ffff881ffa7a9a70       0     0     0     0
  201 ffff881fd9cea800   VxDMP5     ffff881ffa7a91a0       0     0     0     0
  201 ffff881fd9ceb400   VxDMP6     ffff881ffc208000       0     0     0     0
  201 ffff881fd9cea000   VxDMP7     ffff881ffc2088d0       0     0     0     0
  201 ffff881fd9cea400   VxDMP8     ffff881ffc2091a0       0     0     0     0
  201 ffff881fd9ceac00   VxDMP9     ffff881ffc209a70       0     0     0     0
  201 ffff881fd9ce9c00   VxDMP10    ffff881ffc20a340       0     0     0     0
  201 ffff881ff4ef1800   VxDMP11    ffff881ff9c55820       0     0     0     0
  201 ffff881fd9ce9800   VxDMP12    ffff881ffc20ac10       0     0     0     0
  201 ffff881fd9ce9000   VxDMP13    ffff881ffc20b4e0       0     0     0     0
  201 ffff881fd9cec400   VxDMP14    ffff881ffc20bdb0       0     0     0     0
  201 ffff881ff635b800   VxDMP15    ffff881ffa727290       0     0     0     0
  201 ffff881fd9cec000   VxDMP16    ffff881ffc20c680       0     0     0     0
   65 ffff881fd51c6c00   sdad       ffff887b54f68000       0     0     0     0
  253 ffff885ffdfa3000   dm-32      ffff885fc4aa0000       0     0     0     0
   65 ffff881fd51c7800   sdae       ffff883ff50e9a70       0     0     0     0
  201 ffff881fedbbdc00   VxDMP17    ffff881ffc20cf50       0     0     0     0
```
