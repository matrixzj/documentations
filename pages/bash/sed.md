---
title: sed
tags: [bash]
keywords: sed
last_updated: Nov 14, 2020
summary: "sed tips"
sidebar: mydoc_sidebar
permalink: bash_sed.html
folder: bash
---

# sed

## How `sed' Works

`sed` maintains two data buffers: the active `pattern` space, and the auxiliary `hold` space. Both are initially empty.

`sed` operates by performing the following cycle on each line of input: first, `sed` reads one line from the input stream, removes any trailing newline, and places it in the `pattern` space. Then commands are executed; each command can have an address associated to it: addresses are a kind of condition code, and a command is only executed if the condition is verified before the command is to be executed.

 When the end of the script is reached, unless the `-n` option is in use, the contents of `pattern` space are printed out to the output stream, adding back the trailing newline. Then the next cycle starts for the next input line.

Unless special commands (like `D`) are used, the pattern space is deleted between two cycles. The hold space, on the other hand, keeps its data between cycles (see commands `h`, `H`, `x`, `g`, `G` to move n data between both buffers).

## commands in `sed`

* `n` outputs the contents of the pattern space and then reads the next line of input without returning to the top of the script. In effect, the next command causes the next line of input to replace the current line in the pattern space. Subsequent commands in the script are applied to the replacement line, not the current line. If the default output has not been suppressed, the current line is printed before the replacement takes place.

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

## replace the 2nd occurance
```bash
$ echo 'Python Python' | sed -e 's/Python/Go/2'
Python Go
```

## get a specific block 

Show info of `eth0` via `ifconfig` 
```bash
$ ifconfig | sed -ne '/^eth0/{:a;N;/\s$/!{ba};p}'
eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1460
        inet 10.0.0.2  netmask 255.255.255.255  broadcast 10.0.0.2
        inet6 fe80::4001:aff:febb:2  prefixlen 64  scopeid 0x20<link>
        ether 42:01:0a:aa:00:02  txqueuelen 1000  (Ethernet)
        RX packets 16363747  bytes 9653164453 (8.9 GiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 15504492  bytes 10165112383 (9.4 GiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```


{% include links.html %}
