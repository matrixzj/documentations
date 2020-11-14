---
title: sed
tags: [bash]
keywords: sed
last_updated: Nov 14, 2020
summary: "sed tips"
sidebar: mydoc_sidebar
permalink: bash_se.html
folder: bash
---

# sed

## replace in a specific range

### replace specific lines match pattern
```bash
$ sudo grep net /etc/sysctl.conf
net.ipv4.ip_forward = 1

$ sudo sed -ne '/^net/s/1/0/p' /etc/sysctl.conf
net.ipv4.ip_forward = 0
```

### replace lines in a range
```bash
$ awk '{if(NR==12)print}' /etc/sysctl.conf
net.ipv4.ip_forward = 1

$ sed -ne '12s/1/0/p' /etc/sysctl.conf
net.ipv4.ip_forward = 0

```

{% include links.html %}
