---
title: Run Script with SNMP
tags: [misc, snmp]
keywords: snmp, script 
last_updated: Aug 6, 2024
summary: "Run a customerized script via snmp"
sidebar: mydoc_sidebar
permalink: misc_run_script_via_snmp.html
folder: Misc
---

# Run Script with SNMP
=====

## SNMP installation
```bash
$ sudo yum install -y net-snmp net-snmp-utils

$ cat <<EOF | sudo tee /etc/snmp/snmpd.conf
syslocation Unknown (edit /etc/snmp/snmpd.conf)
syscontact Root <root@localhost> (configure /etc/snmp/snmp.local.conf)
dontLogTCPWrappersConnects yes
rocommunity public
EOF
```

Verify
```bash
$ snmpwalk -v2c -c public localhost .1.3.6.1.4.1.2021.4.5
UCD-SNMP-MIB::memTotalReal.0 = INTEGER: 3880016 kB
```

## Create Script on target host
```bash
$ cat <<EOF> /tmp/os_info.sh
#!/bin/bash

cat /etc/os-release  | awk -F'=' '/^NAME/{print $2}' | sed -e 's/"//g'
EOF

$ sudo chmod 755 /tmp/os_info.sh
```

## Add script in SNMP config
```bash
$ cat << EOF | sudo tee -a /etc/snmp/snmpd.conf
extend  osname  /tmp/os_info.sh
EOF

$ sudo systemctl restart snmpd
```

## Retrieve result via snmpwalk/snmpget
```bash
$ snmpwalk -v 2c -c public localhost NET-SNMP-EXTEND-MIB::nsExtendObjects
NET-SNMP-EXTEND-MIB::nsExtendNumEntries.0 = INTEGER: 1
NET-SNMP-EXTEND-MIB::nsExtendCommand."osname" = STRING: /tmp/os_info.sh
NET-SNMP-EXTEND-MIB::nsExtendArgs."osname" = STRING:
NET-SNMP-EXTEND-MIB::nsExtendInput."osname" = STRING:
NET-SNMP-EXTEND-MIB::nsExtendCacheTime."osname" = INTEGER: 5
NET-SNMP-EXTEND-MIB::nsExtendExecType."osname" = INTEGER: exec(1)
NET-SNMP-EXTEND-MIB::nsExtendRunType."osname" = INTEGER: run-on-read(1)
NET-SNMP-EXTEND-MIB::nsExtendStorage."osname" = INTEGER: permanent(4)
NET-SNMP-EXTEND-MIB::nsExtendStatus."osname" = INTEGER: active(1)
NET-SNMP-EXTEND-MIB::nsExtendOutput1Line."osname" = STRING: NAME=CentOS Linux
NET-SNMP-EXTEND-MIB::nsExtendOutputFull."osname" = STRING: NAME=CentOS Linux
NET-SNMP-EXTEND-MIB::nsExtendOutNumLines."osname" = INTEGER: 1
NET-SNMP-EXTEND-MIB::nsExtendResult."osname" = INTEGER: 0
NET-SNMP-EXTEND-MIB::nsExtendOutLine."osname".1 = STRING: NAME=CentOS Linux

$ snmpget -v 2c -c public localhost NET-SNMP-EXTEND-MIB::nsExtendOutLine.\"osname\".1
NET-SNMP-EXTEND-MIB::nsExtendOutLine."osname".1 = STRING: CentOS Linux
```

{% include links.html %}
