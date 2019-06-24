---
title: HP iLO 
tags: [misc]
keywords: iLO, ssh, script 
last_updated: June 24, 2019
summary: "HP iLO related stuffs"
sidebar: mydoc_sidebar
permalink: misc_hpilo.html
folder: Misc
---

## HP iLO
=====

### Gather iLO info for a subnet

```python
#!/usr/bin/env python
#-*- coding: utf-8 -*-

import nmap
from sys import argv
import hpilo
import sys

script, iLONetwork = argv
userid='admin'
passwd='admin'

iLOInfoDict = {}

def probeiLOInfo(_iLOIPAddr):
    iloAddr = _iLOIPAddr
    ilo = hpilo.Ilo(iloAddr, userid, passwd)

    # parse iLO Type
    iLOMajorVersion = ilo.get_fw_version()['management_processor']

    # parse iLO Ver
    iLOMinorVersion = ilo.get_fw_version()['firmware_version']

    # parse HW Type
    iLOHardwareType = ilo.get_product_name().replace('ProLiant ', '')

    # probe FQDN info
    iLOServerFQDN = ilo.get_server_name()

    # probe iLO FQDN Info
    iLOHostname = ilo.get_network_settings()['dns_name']
    iLODomain = ilo.get_network_settings()['domain_name']
    iLOFQDN = iLOHostname + '.' + iLODomain

    iLOInfoDict[_iLOIPAddr] = (iLOMajorVersion, iLOMinorVersion, iLOHardwareType, iLOServerFQDN, iLOFQDN)

nm = nmap.PortScanner()
networkScanResult = nm.scan(hosts=iLONetwork, arguments='-n -P0 -sS -p 17988')

iLOAliveHostsList = []
for key in networkScanResult['scan']:
    if networkScanResult['scan'][key]['tcp'][17988]['state'] == 'open':
        iLOAliveHostsList.append(key)

iLOAliveHostsList.sort()

for iLOHost in iLOAliveHostsList:
    probeiLOInfo(iLOHost)

printFormat = '%-15s\t%8s %8s %-12s\t%-31s\t%-31s'

print printFormat % ('-' * 15, '-' * 8, '-' * 8, '-' * 12, '-' * 31, '-' * 31)
print printFormat % ('iLO IP Address', 'iLO Type', 'iLO Ver', 'Server Model', 'iLO Server FQDN', 'iLO FQDN')
print printFormat % ('-' * 15, '-' * 8, '-' * 8, '-' * 12, '-' * 31, '-' * 31)


for i in iLOInfoDict:
    print printFormat % (i, iLOInfoDict[i][0], iLOInfoDict[i][1], iLOInfoDict[i][2], iLOInfoDict[i][3], iLOInfoDict[i][4])
```

[Modify images](https://docs.openstack.org/image-guide/modify-images.html)

{% include links.html %}
