---
title: CA(Certificate Authority)
tags: [idm]
keywords: certs, tls, ssl
last_updated: July 7th, 2019
summary: "Self-signed CA Setup"
sidebar: mydoc_sidebar
permalink: idm_ca.html
folder: idm
---

CA(Certificate Authority)
======

### Certs Path Config  
Open `/etc/pki/tls/openssl.cnf`, find the section labeled `[ CA_default ]`, and edit as the following:

```bash
dir = /etc/pki/CA
certificate = $dir/my-ca.crt
crl = $dir/my-ca.crl
private_key = $dir/private/my-ca.key
```

### Certs Info

The `[ req_distinguished_name ]` section lists several default options for authorized certs
```bash
countryName_default = US
stateOrProvinceName_default = New York
localityName_default = New York
0.organizationName_default = Example
```

### Cert Matching Policy

Policy choosen was in section `[ CA_default ]`
```bash
policy          = policy_match
```





{% include links.html %}
