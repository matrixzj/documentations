---
title: Decrypt ssh private key with `openssl`
tags: [idm]
keywords: ssh, key, openssl 
last_updated: Oct 1, 2020
summary: "How to decrypt ssh private key with openssl"
sidebar: mydoc_sidebar
permalink: idm_decrypt_ssh_private_key_with_openssl.html
folder: idm
---

Decrypt ssh private key with `openssl`
======

### Generate a passwork protected ssh key pairs

```bash
$ ssh-keygen -N '123456' -f id_rsa.test
Generating public/private rsa key pair.
Your identification has been saved in id_rsa.test.
Your public key has been saved in id_rsa.test.pub.
The key fingerprint is:
SHA256:mFRi7jKygtkD4iaFm9K5MdMQNGoUviGVlG2h5u4Bm+U matrix@testbox
The key's randomart image is:
+---[RSA 2048]----+
| +*+..o .        |
|o+oooo o         |
|o++.  o          |
|o+o. o o         |
|=.* o + S        |
|+/ * o           |
|@oE .            |
|+o B             |
|  o              |
+----[SHA256]-----+

$ ls -al id_rsa.test*
-rw-------. 1 jun_zou jun_zou 1766 Oct  1 09:33 id_rsa.test
-rw-r--r--. 1 jun_zou jun_zou  404 Oct  1 09:33 id_rsa.test.pub

$ cat id_rsa.test
-----BEGIN RSA PRIVATE KEY-----
Proc-Type: 4,ENCRYPTED
DEK-Info: AES-128-CBC,36F462CA7FDC739ABB7C7892C2437FA9

biSm9q1nq3Zebu9Ex1DO/Hf0T08enYb8b+dVUe3OxaXG9PKVsFvvzTTza/2cXQWi
A/EV0M35M7LM1pGPcjIKlnZ5RRj74DATZ4vLqIYTpR0OumdUcL5mvLFjmBTzZ/GU
TipD8VOjLA4T/xcTclPeXtK4jz4/DmN6ctu4AS20i+z0OrOyQeGPVg28pzISUUjH
bVbkZt889N798UE2KOE0JgPEz6A4QBtV/5cBoGzaPWzbrlmXEylb4EFrDy/XJM3D
Yg6OdaKxWZzuYIwtCZdSfMv3e1E97eN+ah/l1FHdhxa0ll673mAlKxdWKCKlY1FK
ymaLghAZAjNKCVCrVlWgbJ8PQ1mQgoqRkc6gqTpR5K7rrgruj9dVhPJYhtg8mKGY
gi5fCkabhsHKjKkNm5qngFRNaRK67vpiUQj3Nu4qioeY1LDmmeTpWPBZ34IvvXJ8
uPfeGlKo5d/5M3iVBQtCDuij3Q8etjuZ80XaRIbyckIAV9YYxu64BTMLvd4QX+/L
ouRZowZ0T8Ob5cLqZAKmgAILZZ2RwGkMKBRxbNv/GmxDalRTSEo0jLYXCGVURY1Z
DRkw5tKtJqEd7Vad5bLd58yEIOmbVHab7XVgPOl61IZaYyYpQDxfEgw64DCzo1RX
XNptpOw278kMdzp3stTuUmNKcaytBnBuoWUj+8k3JUr6Pkz1IElHoAZ5s7fvFuQW
8pl5mWAbR8FJV/0i/QTLTVGhpci39/Hfgj26Ew5AhPQDuq6I0GxQFduatSe/g9Hz
/3cZN0LM39EbBjf44sPrmIKFYcXQir1DuQNDX10Yd6qC9TIO9146WD8MNLvidi4R
4PTCAGs2ZZ5rkhoHzNuG30lM01pkg6SvH4UmNDqxQ6Zj5Uq5JWhriqIJ/QH7vghI
fIxdvuG37nbdkZuXyJmmfohDTfQeH933mIHVR7FLWdAvZpnZkhOtecgjb72c+NaD
SgZ/JAm8wMVBGSGaH8iKC+x7VQgF5jJ5SjpvEuoq3I+x8nrPkLR0soVeUrqXONRH
heaVhejAnQxQa3B/hbzSkOCkJ+dgfUI6IUUg8a8Syr35b9xb2A4en0lK+tH0nVAk
wZIFKlsRazmv4RVqU3i3SfvzG/tymIddK/2og2Ai+BUWN4gHCYkFk9M8vLDdC8Zb
ErhY6mIRGR3liSxOLJH73b7HeDZjdBz3XJjLFCcRkl7eBwtwroShgWPI0WRSQo94
jMmeNkvAdsEi8Rzz0AwmEtsSD5WxSGYngGgluLaCi2Dhpxy0irJfW5ex+Jg6jih8
wMFa5uFWcN6vSytwzGQZVLt5zCrpKnDZGvA3CQtDfQVgTRbmh003qBC7dfVuLWdi
5z9UN7811f1yfgxa9gK3r8TpUFNMCX+oNS7VYzfDpf9TzB9AlnnGOsOdkurRRm/t
Oa9+ld8yl6rvifed8ScY3PQHpWIEUezQlFFSabCrp4YRPAE8I30wiN4GDLmUczna
W7G2yfAPMtmpr6hyz4CaDONx9KS7reW6v33S+L3NVg48dYXLEQsVlcUln1Bdg6ZX
kRnzl39TSDBCK05lroje5WLtfoRRqcyvYyH5L9ax74NeLU/PY2HJ2h/DAVLY71lF
-----END RSA PRIVATE KEY-----

```

### Decrypt ssh key

```bash
$ openssl rsa -in id_rsa.test -passin "pass:123456" > id_rsa.test.decrypted
writing RSA key

$ cat id_rsa.test.decrypted
-----BEGIN RSA PRIVATE KEY-----
MIIEogIBAAKCAQEAoTPdGNLpM9m9qAqdXGuSnwROsCboV0Gt9KUPyzJmQDUogHaR
HgASLeHMekozhqwLd2JGbgpF/kkfk5u/rBW+Y4fFspWDo3aN+9xu9G1EmOyxB9Q5
P9rLjGykvjkq73nobbYetpvXlnB+6P0S73fzHmFHZPGGD8rDk7ONlJBrgLjEOoUO
ej7Hyf+DFwjsPCvdp72kPwidsfMVXhSUIzisMqlxqiL8xt3J2IapIOIrdU16JZMR
X2FCgm9Qeak91/9CF0IPNoUu+zaU6iWwOPjHIHDQFAN/xCc62T820DSkX7H/+6qh
PoNrixuNodIoUvmDFdjN267hXC4TLc/5dgXQIwIDAQABAoIBAB+Y+Oeav9dIAOLl
Yb7x3wWIZJwmpDgmSaDAkf30XRKM2OmFVCCbRvTzY4886CinpH+8Ja4AGYQkdSoL
x2BFytHblSbSI8FwxZfut1j16hJHotO0B5y6mFdoHEqlDgNu095dalvE5Fc6qcWl
hYam7mKwErx4kxyZVAipk0DhphDO1w1hAmPVv5pQwehNSLfvxpFOA8xpQj/omSCi
Vx/s8J4ZJmVzqRDDaN8WsSDdoXmZKZhXCKa8ERwL0Xi2Unym0AqwLTh6b7LjFh4x
KRK1/X8CTwQYtkMOdX4PvIUFW6FLcypqrIlo0JfXcPqGKpVNyMHo6aLDW7snLTiG
7eg72nECgYEA0IcP5YevgMZ948LQgKcLQkqEcChIXPgO7JnnbXqginTFIw4Zenv7
ldft9gUKR00OxOCrj65fWkljE0ef4W3F9hgkZ07DNFWZ+oh5mWZCF7weWioNgY//
ZvzDagOEHFDhPexLs/zY5kUEHdTg80NYF8kAZXI9MOa+1zgzRyhkWP0CgYEAxea2
VJLmky2/UPMQ0nfnCy5CtQ6PLQ2xcNe3f6dHF5jzAR2wqG1PdTK0g+1a7vlH7lqd
HTeW5RJoeiptk61G38ud1kkYQ/T9ol4FEGiiMdK6r3+1TF4SDgqxZVD6A644k2Pz
Nv1nhXXCchzpc/cw5vtYRwS0zFkocO9aAen0J58CgYAemyQ/KSoeOYPysP5PU7U4
Vp2XpKHyW0o9ed1Y2T3E9JyWp5QfwSDM/nNjv5uhmXLIfL1RimNeahULmGCkAqui
kiqNqybFgKbn+a33UOX0e9zsmO2AjbUL1Z+M6NU0Hr7gitUVps/jBFA1XLBjpAfC
/fJ78Ud/7O4nwozsLcaEtQKBgFwwIiV5nQFYoTOTVvXENxOlRBvVoWqqY0seofNM
ODjM3f5aF04ORaJhsWd3bRG/e/uTqHbQy3EARz0JgKv3Xvmnf2ov+KbHfFNjmtZO
96df8+kHA6yEccKqxoJc22pVgTNfrw+hsdSgy6iewT1tHBGtai0DCznaGpWpWfNk
SYEfAoGASmtR/VFbNxjNE9tlihHtC89js1HFv7bsSlslMNPp6DQckn6PYOk3f5Uu
3MS6Gf349wpmJ8NLDMhp4WJB7Z/F14KbAYYdRwmpbQsSebpFeDiNF9OY2EAOI52L
OB3ynrGKIXcRrT+3HGkpIXT9JglEuWkqXXMwlg25gB35WLQ2Geg=
-----END RSA PRIVATE KEY-----
```


### Inspect ssh public key fingerprint

```bash
$ ssh-keygen -l -f id_rsa.test.pub
2048 SHA256:mFRi7jKygtkD4iaFm9K5MdMQNGoUviGVlG2h5u4Bm+U jun_zou@matrix-jumpbox (RSA)

$ ssh-keygen -E md5 -l -f id_rsa.test.pub
2048 MD5:eb:c8:75:82:b1:23:36:31:34:7b:4c:44:c4:21:59:e0 jun_zou@matrix-jumpbox (RSA)
```

{% include links.html %}
