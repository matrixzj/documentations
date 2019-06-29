---
title: HP iLO 
tags: [misc]
keywords: iLO, ssh, script 
last_updated: June 29, 2019
summary: "HP iLO related stuffs"
sidebar: mydoc_sidebar
permalink: misc_hpilo.html
folder: Misc
---

## HP iLO
=====

### Gather iLO info for a subnet with python lib `hpilo`

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

Result Example:
```bash
 $ sudo ./gather_ilo_info_v1.py 192.168.100.0/24
--------------- -------- -------- ------------  ------------------ ----------------------
iLO IP Address  iLO Type  iLO Ver Server Model  iLO Server FQDN    iLO FQDN
--------------- -------- -------- ------------  ------------------ ----------------------
192.168.100.51      iLO4     2.50 DL380p Gen8   ilo01.example.net  ilo01-iLO.example.net
192.168.100.50      iLO4     2.50 DL380p Gen8   ilo02.example.net  ilo02-iLO.example.net
192.168.100.53      iLO4     2.50 DL360 Gen9    ilo03.example.net  ilo03-iLO.example.net
192.168.100.52      iLO3     1.85 DL380 G7      ilo04.example.net  ilo04-iLO.example.net
192.168.100.212     iLO4     2.50 DL360 Gen9    ilo05.example.net  ilo05-iLO.example.net
```

### Gather iLO info for a subnet with iLO restful API

```python
#!/usr/bin/env python
#-*- coding: utf-8 -*-

import nmap
from sys import argv
from httplib import HTTPSConnection
from base64 import b64encode
import json
import xml.etree.ElementTree
import urllib2

script, iLONetwork = argv
userid='admin'
passwd='admin'

iLOInfoDict = {}

def probeiLOInfo(_iLOIPAddr):
    auth='BASIC ' + b64encode(userid + ":" + passwd)
    header = {'Authorization': auth}

    conn = HTTPSConnection(host=_iLOIPAddr, strict=True)

    iLOInfoURL = 'http://' + _iLOIPAddr + '/xmldata?item=All'
    iLOPage = urllib2.urlopen(iLOInfoURL)
    iLOXML = xml.etree.ElementTree.parse(iLOPage)
    iLOXMLRoot = iLOXML.getroot()

    # parse iLO Type
    for i in iLOXMLRoot.iter('PN'):
        iLOMajorVersion = i.text.split('(')[1].split(')')[0]

    # parse iLO Ver
    for i in iLOXMLRoot.iter('FWRI'):
        iLOMinorVersion = i.text

    # parse HW Type
    for i in iLOXMLRoot.iter('SPN'):
        iLOHardwareType = i.text

    # probe FQDN info
    if iLOMajorVersion == 'iLO 4':
        conn.request('GET', '/rest/v1/Managers/1/NetworkService', headers=header)
        iLOResponse = conn.getresponse().read().split("'")[0]
        iLOResponseDict = json.loads(iLOResponse)
        iLOFQDN = iLOResponseDict['FQDN']
        conn.close()
    else:
        iLOFQDN = 'unknown'

    iLOInfoDict[_iLOIPAddr] = (iLOMajorVersion, iLOMinorVersion, iLOHardwareType, iLOFQDN)

nm = nmap.PortScanner()
networkScanResult = nm.scan(hosts=iLONetwork, arguments='-n -P0 -sS -p 17988')

iLOAliveHostsList = []
for key in networkScanResult['scan']:
    if networkScanResult['scan'][key]['tcp'][17988]['state'] == 'open':
        iLOAliveHostsList.append(key)

iLOAliveHostsList.sort()

for iLOHost in iLOAliveHostsList:
        probeiLOInfo(iLOHost)


print '''
--------------- -------- ------- ---------------------- -------------------------------
iLO IP Address  iLO Type iLO Ver       Server Model           iLO FQDN
--------------- -------- ------- ---------------------- -------------------------------'''

for i in iLOInfoDict:
    print '%-15s %7s %-8s %-22s %-s' % (i, iLOInfoDict[i][0], iLOInfoDict[i][1], iLOInfoDict[i][2], iLOInfoDict[i][3])
```

Result:
```bash
$ su - 

# export PYTHONHTTPSVERIFY=0

# ./gather_ilo_info.py 192.168.100.0/24
--------------- -------- -------- ------------  ------------------
iLO IP Address  iLO Type  iLO Ver Server Model  iLO Server FQDN   
--------------- -------- -------- ------------  ------------------
192.168.100.51      iLO4     2.50 DL380p Gen8   ilo01.example.net               
192.168.100.50      iLO4     2.50 DL380p Gen8   ilo02.example.net               
192.168.100.53      iLO4     2.50 DL360 Gen9    ilo03.example.net               
192.168.100.52      iLO3     1.85 DL380 G7      ilo04.example.net               
192.168.100.212     iLO4     2.50 DL360 Gen9    ilo05.example.net               
```

###  Set One-Time Boot Device

```
#!/usr/bin/env python
#-*- coding: utf-8 -*-

from sys import argv
import hpilo

script, iiloAddr = argv
userid='admin'
passwd='admin'

import hpilo

ilo = hpilo.Ilo(iloAddr, userid, passwd)

# list current boot sequence
# output:  ['cdrom', 'usb', 'hdd', 'network1']
ilo. get_persistent_boot()

# get current one-time boot device
# output: 'normal'
ilo.get_one_time_boot()

# set one time boot device 
# Options: normal, floppy, cdrom, hdd, usb, rbsu, network
ilo.set_one_time_boot('network')
```

[iLO automation from python or shell](https://seveas.github.io/python-hpilo/index.html)

{% include links.html %}
