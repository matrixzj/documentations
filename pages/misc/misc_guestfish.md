---
title: Modify VM Image without Starting It
tags: [misc]
keywords: guestfish, qcow2, raw, image
last_updated: June 23, 2019
summary: "Edit VM Image with guestfish tool"
sidebar: mydoc_sidebar
permalink: misc_guestfish.html
folder: Misc
---

## Modify VM Image without Starting It
=====

### Load  image file with guestfish

```bash
# guestfish --rw -a /export/data/kvm/images/image.qcow2

Welcome to guestfish, the guest filesystem shell for
editing virtual machine filesystems and disk images.

Type: ‘help’ for help on commands
      ‘man’ to read the manual
      ‘quit’ to quit the shell

><fs> run
 100% ⟦▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒⟧ 00:00
```

### List available devices

```bash
><fs> list-filesystems
/dev/sda1: ext4
/dev/sda2: ext4

><fs> mount /dev/sda2 /
```

### Add/Remove file attributes
```bash
><fs> get-e2attrs /etc/resolv.conf
ei
><fs> set-e2attrs /etc/resolv.conf i clear:true
><fs> get-e2attrs /etc/resolv.conf
e
```

[Modify images](https://docs.openstack.org/image-guide/modify-images.html)

{% include links.html %}
