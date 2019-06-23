---
title: NFS Retransmission
tags: [filesystem]
keywords: nfs, retransmission
last_updated: June 17, 2019
summary: "NFS Retransmission mechanism"
sidebar: mydoc_sidebar
permalink: filesystem_nfs_retransmission.html
folder: filesystem
---

## Mac Reinstallation Steps
=====

### Install Brew
[Homebrew](https://brew.sh/)

```bash
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

### Install zsh
[on-my-zsh github repo](https://github.com/robbyrussell/oh-my-zsh)

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
```

### Karabiner Complex Modifications

complex modifications config location
```bash
/Users/jzou/.config/karabiner/assets/complex_modifications
```

### Virt-Manager on Mac
[virt-manager on Mac github repo](https://github.com/jeffreywildman/homebrew-virt-manager)

```bash
brew tap jeffreywildman/homebrew-virt-manager
brew install virt-manager virt-viewer
```

### iStart Menus Activation Key

```bash
Email: 982092332@qq.com
SN: GAWAE-FCWQ3-P8NYB-C7GF7-NEDRT-Q5DTB-MFZG6-6NEQC-CRMUD-8MZ2K-66SRB-SU8EW-EDLZ9-TGH3S-8SGA
```

### Set New Hostname

```bash
sudo scutil --set HostName <new host name>
sudo scutil --set LocalHostName <new host name>
sudo scutil --set ComputerName <new name>
dscacheutil -flushcache
```
reboot to take it in effect

### Mail Signature

{% include links.html %}
