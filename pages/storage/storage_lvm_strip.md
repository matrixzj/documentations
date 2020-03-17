---
title: LVM Strip
tags: [storage]
keywords: lvm, strip, raid
last_updated: Feb 29, 2020
summary: "something about lvm strip"
sidebar: mydoc_sidebar
permalink: storage_lvm_strip.html
folder: storage
---

LVM Strip
======

### How to Creat a Striped LVM
```
# lvcreate --type striped --stripes 2 --stripesize 256 vg1  -n lv_export -l 1526178 /dev/sda /dev/sdb

$ cat /etc/lvm/backup/vg1
# Generated by LVM2 version 2.02.168(2) (2016-11-30): Thu Feb 27 07:38:24 2020

contents = "Text Format Volume Group"
version = 1

description = "Created *after* executing 'lvcreate --type striped --stripes 2 --stripesize 128 vg1 -n lv_export -l 1526178 /dev/sda /dev/sdb'"

creation_host = "host1.example.com"       # Linux host1.exampletv.com 4.9.0-11-amd64 #1 SMP Debian 4.9.189-3+deb9u2 (2019-11-11) x86_64
creation_time = 1582807104      # Thu Feb 27 07:38:24 2020

vg1 {
        id = "7ISf3c-EyNh-H1I7-GUJU-xA9b-m519-leUFLf"
        seqno = 2
        format = "lvm2"                 # informational
        status = ["RESIZEABLE", "READ", "WRITE"]
        flags = []
        extent_size = 8192              # 4 Megabytes
        max_lv = 0
        max_pv = 0
        metadata_copies = 0

        physical_volumes {

                pv0 {
                        id = "QX8y4x-EQPO-PVUR-yvoG-Qg9l-PxZq-PZWQ4f"
                        device = "/dev/sda" # Hint only

                        status = ["ALLOCATABLE"]
                        flags = []
                        dev_size = 6251233968   # 2.91096 Terabytes
                        pe_start = 2048
                        pe_count = 763089       # 2.91095 Terabytes
                }

                pv1 {
                        id = "4W1wAI-fLHP-8HFj-4EJp-WZ8m-006q-IWIdDn"
                        device = "/dev/sdb" # Hint only

                        status = ["ALLOCATABLE"]
                        flags = []
                        dev_size = 6251233968   # 2.91096 Terabytes
                        pe_start = 2048
                        pe_count = 763089       # 2.91095 Terabytes
                }
        }

        logical_volumes {

                lv_export {
                        id = "yPjmOp-MOx3-ZkA2-Sn7l-IKmI-ItMN-D5VR7P"
                        status = ["READ", "WRITE", "VISIBLE"]
                        flags = []
                        creation_time = 1582807104      # 2020-02-27 07:38:24 -0500
                        creation_host = "host1.example.com"
                        segment_count = 1

                        segment1 {
                                start_extent = 0
                                extent_count = 1526178  # 5.82191 Terabytes

                                type = "striped"
                                stripe_count = 2
                                stripe_size = 256       # 128 Kilobytes

                                stripes = [
                                        "pv0", 0,
                                        "pv1", 0
                                ]
                        }
                }
        }

}

```  

### Try Sequential Write with `dd` and verify it with `blktrace`
```
# dd if=/dev/zero of=/export/test.img bs=16k count=1920000 oflag=direct
```

As blocksize is set to `16k` in `dd`, `8` requests will be sent to 1 underneath device then switch to another one since stripe size in lvm was set to `128k`.
```
259,2   13       57     0.000514041  3272  A  WS 89662304 + 32 <- (254,0) 179320416
259,2   13       64     0.000545028  3272  A  WS 89662336 + 32 <- (254,0) 179320448
259,2   13       71     0.000575317  3272  A  WS 89662368 + 32 <- (254,0) 179320480
259,2   13       78     0.000606383  3272  A  WS 89662400 + 32 <- (254,0) 179320512
259,2   13       85     0.000637837  3272  A  WS 89662432 + 32 <- (254,0) 179320544
259,0   13       57     0.000668819  3272  A  WS 89662208 + 32 <- (254,0) 179320576
259,0   13       64     0.000700293  3272  A  WS 89662240 + 32 <- (254,0) 179320608
259,0   13       71     0.000731709  3272  A  WS 89662272 + 32 <- (254,0) 179320640
259,0   13       78     0.000763453  3272  A  WS 89662304 + 32 <- (254,0) 179320672
259,0   13       85     0.000794049  3272  A  WS 89662336 + 32 <- (254,0) 179320704
259,0   13       92     0.000824249  3272  A  WS 89662368 + 32 <- (254,0) 179320736
259,0   13       99     0.000855601  3272  A  WS 89662400 + 32 <- (254,0) 179320768
259,0   13      106     0.000886607  3272  A  WS 89662432 + 32 <- (254,0) 179320800
259,2   13       92     0.000917480  3272  A  WS 89662464 + 32 <- (254,0) 179320832
259,2   13       99     0.000948469  3272  A  WS 89662496 + 32 <- (254,0) 179320864
259,2   13      106     0.000980183  3272  A  WS 89662528 + 32 <- (254,0) 179320896
259,2   13      113     0.001017346  3272  A  WS 89662560 + 32 <- (254,0) 179320928
259,2   13      120     0.001049972  3272  A  WS 89662592 + 32 <- (254,0) 179320960
259,2   13      127     0.001081212  3272  A  WS 89662624 + 32 <- (254,0) 179320992
259,2   13      134     0.001112461  3272  A  WS 89662656 + 32 <- (254,0) 179321024
259,2   13      141     0.001143800  3272  A  WS 89662688 + 32 <- (254,0) 179321056
259,0   13      113     0.001175234  3272  A  WS 89662464 + 32 <- (254,0) 179321088
259,0   13      120     0.001206920  3272  A  WS 89662496 + 32 <- (254,0) 179321120
259,0   13      127     0.001237859  3272  A  WS 89662528 + 32 <- (254,0) 179321152
259,0   13      134     0.001268335  3272  A  WS 89662560 + 32 <- (254,0) 179321184
259,0   13      141     0.001299716  3272  A  WS 89662592 + 32 <- (254,0) 179321216
259,0   13      148     0.001330172  3272  A  WS 89662624 + 32 <- (254,0) 179321248
259,0   13      155     0.001361460  3272  A  WS 89662656 + 32 <- (254,0) 179321280
259,0   13      162     0.001391684  3272  A  WS 89662688 + 32 <- (254,0) 179321312
259,2   13      148     0.001423254  3272  A  WS 89662720 + 32 <- (254,0) 179321344
259,2   13      155     0.001455034  3272  A  WS 89662752 + 32 <- (254,0) 179321376
259,2   13      162     0.001486733  3272  A  WS 89662784 + 32 <- (254,0) 179321408
259,2   13      169     0.001517787  3272  A  WS 89662816 + 32 <- (254,0) 179321440 
```


{% include links.html %}