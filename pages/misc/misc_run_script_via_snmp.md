---
title: Run Script with SNMP
tags: [misc, snmp]
keywords: snmp, script 
last_updated: April 5, 2020
summary: "Run a customerized script via snmp"
sidebar: mydoc_sidebar
permalink: misc_run_script_via_snmp.html
folder: Misc
---

# Run Script with SNMP
=====

## Create Script on target host
```bash
$ sudo cat /root/os_info.sh
#!/bin/bash

cat /etc/os-release  | awk -F'=' '/^NAME/{print $2}' | sed -e 's/"//g'

$ sudo chmod 755 /root_info.sh
```

## Add script in SNMP config
```bash
# cat << EOF >> /etc/snmp/snmpd.conf
extend  osname  /root/os_info.sh
EOF

# systemctl restart snmpd
```

## Retrieve result via snmpwalk/snmpget
```bash
$ snmpwalk -v 2c -c ro_community demo.example.net NET-SNMP-EXTEND-MIB::nsExtendObjects
NET-SNMP-EXTEND-MIB::nsExtendNumEntries.0 = INTEGER: 1
NET-SNMP-EXTEND-MIB::nsExtendCommand."osname" = STRING: /root/os_info.sh
NET-SNMP-EXTEND-MIB::nsExtendArgs."osname" = STRING:
NET-SNMP-EXTEND-MIB::nsExtendInput."osname" = STRING:
NET-SNMP-EXTEND-MIB::nsExtendCacheTime."osname" = INTEGER: 5
NET-SNMP-EXTEND-MIB::nsExtendExecType."osname" = INTEGER: exec(1)
NET-SNMP-EXTEND-MIB::nsExtendRunType."osname" = INTEGER: run-on-read(1)
NET-SNMP-EXTEND-MIB::nsExtendStorage."osname" = INTEGER: permanent(4)
NET-SNMP-EXTEND-MIB::nsExtendStatus."osname" = INTEGER: active(1)
NET-SNMP-EXTEND-MIB::nsExtendOutput1Line."osname" = STRING: CentOS Linux
NET-SNMP-EXTEND-MIB::nsExtendOutputFull."osname" = STRING: CentOS Linux
NET-SNMP-EXTEND-MIB::nsExtendOutNumLines."osname" = INTEGER: 1
NET-SNMP-EXTEND-MIB::nsExtendResult."osname" = INTEGER: 0
NET-SNMP-EXTEND-MIB::nsExtendOutLine."osname".1 = STRING: CentOS Linux

$ snmpget -v 2c -c fwnetm0n bjoops03.dev.fwmrm.net NET-SNMP-EXTEND-MIB::nsExtendOutLine.\"osname\".1
NET-SNMP-EXTEND-MIB::nsExtendOutLine."osname".1 = STRING: CentOS Linux
```

{% include links.html %}
