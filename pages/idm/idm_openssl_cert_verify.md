---
title: Verify Certs with `openssl`
tags: [idm]
keywords: ssl, certs, openssl 
last_updated: Sep 14, 2020
summary: "How to verify certs with openssl"
sidebar: mydoc_sidebar
permalink: idm_verify_certs_with_openssl.html
folder: idm
---

Verify Certs with `openssl`
======

### Verify with public CA 

```bash
$ openssl s_client -connect www.google.com:443 < /dev/null
CONNECTED(00000003)
depth=2 OU = GlobalSign Root CA - R2, O = GlobalSign, CN = GlobalSign
verify return:1
depth=1 C = US, O = Google Trust Services, CN = GTS CA 1O1
verify return:1
depth=0 C = US, ST = California, L = Mountain View, O = Google LLC, CN = www.google.com
verify return:1
---
Certificate chain
 0 s:/C=US/ST=California/L=Mountain View/O=Google LLC/CN=www.google.com
   i:/C=US/O=Google Trust Services/CN=GTS CA 1O1
 1 s:/C=US/O=Google Trust Services/CN=GTS CA 1O1
   i:/OU=GlobalSign Root CA - R2/O=GlobalSign/CN=GlobalSign
---
Server certificate
-----BEGIN CERTIFICATE-----
MIIFkzCCBHugAwIBAgIRAL3V5rIcUgLpCAAAAABWBREwDQYJKoZIhvcNAQELBQAw
QjELMAkGA1UEBhMCVVMxHjAcBgNVBAoTFUdvb2dsZSBUcnVzdCBTZXJ2aWNlczET
MBEGA1UEAxMKR1RTIENBIDFPMTAeFw0yMDA4MjYwODAyNDZaFw0yMDExMTgwODAy
NDZaMGgxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpDYWxpZm9ybmlhMRYwFAYDVQQH
Ew1Nb3VudGFpbiBWaWV3MRMwEQYDVQQKEwpHb29nbGUgTExDMRcwFQYDVQQDEw53
d3cuZ29vZ2xlLmNvbTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAK5T
bteR05HLDfPlhuCgGYcrGyVuJqO68rgtXPnEFIblRj6FW/fegTgRQCXQZFK6cjOj
vYNtzrDOYz1HwWWdNW0aAbTffdtUsMFKIwPEMgy8ZEod5M0L4Z8Qz0lnlwhGpzHu
bVupjyWASpjEZEunhPLr5C5gEL2LV5EA8t+pgmIXLOf7oNaryl3BquPmHGo+eAW0
hBobE00BOrw6eCxTNQaTTqnBJRWupQTgDs0b4NUYAlgERfACQl6J2sarDDNDzIIW
DYABuhgW0/M4p9KNbHcGWTjJ728XpJHBp9x+hwjtcXUAMsgNaBjBwvwrFltPKCls
vfsdt8vCisTmVsRte5ECAwEAAaOCAlwwggJYMA4GA1UdDwEB/wQEAwIFoDATBgNV
HSUEDDAKBggrBgEFBQcDATAMBgNVHRMBAf8EAjAAMB0GA1UdDgQWBBSzcZBN2cvn
2c+vyEIY64PD8pm5MzAfBgNVHSMEGDAWgBSY0fhuEOvPm+xgnxiQG6DrfQn9KzBo
BggrBgEFBQcBAQRcMFowKwYIKwYBBQUHMAGGH2h0dHA6Ly9vY3NwLnBraS5nb29n
L2d0czFvMWNvcmUwKwYIKwYBBQUHMAKGH2h0dHA6Ly9wa2kuZ29vZy9nc3IyL0dU
UzFPMS5jcnQwGQYDVR0RBBIwEIIOd3d3Lmdvb2dsZS5jb20wIQYDVR0gBBowGDAI
BgZngQwBAgIwDAYKKwYBBAHWeQIFAzAzBgNVHR8ELDAqMCigJqAkhiJodHRwOi8v
Y3JsLnBraS5nb29nL0dUUzFPMWNvcmUuY3JsMIIBBAYKKwYBBAHWeQIEAgSB9QSB
8gDwAHYAB7dcG+V9aP/xsMYdIxXHuuZXfFeUt2ruvGE6GmnTohwAAAF0KgFdXAAA
BAMARzBFAiEA6siyoMwNEQIjaOCqCu+IpLZjpweNeMIQqPm0NbEoJzYCIBXvIZlb
2q7BY/GNFfxYsf+WlU0TWHyYpo81ZW7sgk00AHYA5xLysDd+GmL7jskMYYTx6ns3
y1YdESZb8+DzS/JBVG4AAAF0KgFdMQAABAMARzBFAiEAtv0Okps5R2uznTLRtu/z
ht7rQffDIbJ2gFGI3sHzqeQCIGybDt894zBBTkDzETkynOj8b4lMI22Pm8YwWvmD
JffYMA0GCSqGSIb3DQEBCwUAA4IBAQCgDP6eByxvPI3Oivb+TRhahrvQermmJmjB
A4PE9GHv6m485aJd77vp1y2yTToRqVxOWobxsw1uEdcLzNVI0fXuitBvuDzGB85A
xMSJobRXfhxdykDsdUtwD6UmrXrhfSgTDwiBMPaR024T9qHf0IILPgOhrOOZuDtx
aauKaSEwlXS/HQda8zYVtSO1YzCrI8k0VzmjTILMGaOKTXhGlBfxFMkxH1IkDP/C
DL7AWVgPuaEKmLBYibYkUddwcsXX79tnFhJMvfw+hOWd0gzNaCO84W0G9VCJ4cqr
hJMVieVf9ZmIJZQWeE3ndgUhrTBwP58D/KgJG6dRcmu7xBnSMs8l
-----END CERTIFICATE-----
subject=/C=US/ST=California/L=Mountain View/O=Google LLC/CN=www.google.com
issuer=/C=US/O=Google Trust Services/CN=GTS CA 1O1
---
No client certificate CA names sent
Peer signing digest: SHA256
Server Temp Key: ECDH, P-256, 256 bits
---
SSL handshake has read 3249 bytes and written 415 bytes
---
New, TLSv1/SSLv3, Cipher is ECDHE-RSA-AES128-GCM-SHA256
Server public key is 2048 bit
Secure Renegotiation IS supported
Compression: NONE
Expansion: NONE
No ALPN negotiated
SSL-Session:
    Protocol  : TLSv1.2
    Cipher    : ECDHE-RSA-AES128-GCM-SHA256
    Session-ID: 3DD7F77C30E1B0A2AA56F0F8C3283B5E4A7CBE0A9961EBDA38D55DF53434632D
    Session-ID-ctx:
    Master-Key: 3BAAE97E0A69DC5FEBB4CFD5D6E1AB92FBB9BBEFD856A0C5737ACF1AC0175D1AD1724A3D45D491105BAACBC8E0954C09
    Key-Arg   : None
    Krb5 Principal: None
    PSK identity: None
    PSK identity hint: None
    TLS session ticket lifetime hint: 100799 (seconds)
    TLS session ticket:
    0000 - 01 17 7d 6e 05 a9 7b d2-ec e8 45 0d 7b a1 0b 3e   ..}n..{...E.{..>
    0010 - 68 f1 ef 06 cd a8 bf 33-5b af c7 3b 39 21 61 13   h......3[..;9!a.
    0020 - 52 e9 5c 65 12 12 23 fd-7e f0 e9 b1 a3 9c 31 08   R.\e..#.~.....1.
    0030 - 5c 44 ea d6 4b 28 40 b3-d7 6f b7 c8 56 43 26 b7   \D..K(@..o..VC&.
    0040 - c8 8e 81 58 fe 9a 2c 8b-41 29 dd a8 e4 fd b7 80   ...X..,.A)......
    0050 - 4d 76 36 bc 36 72 bd e2-dc b6 84 98 2a 06 47 07   Mv6.6r......*.G.
    0060 - 4a 26 f1 83 bf 9e f2 2c-f9 4f fe 31 c4 0d 64 2f   J&.....,.O.1..d/
    0070 - 5e 6f d2 db 4f 2e 36 97-0b a8 ed 5d 6b 91 3a 70   ^o..O.6....]k.:p
    0080 - c2 24 fd 5e f8 c3 3e e8-bb e4 24 52 d0 a4 f1 f1   .$.^..>...$R....
    0090 - b4 ba 3d da 2b a4 82 b8-8b d0 04 10 7c 1e cc 40   ..=.+.......|..@
    00a0 - 8c 3b 21 e0 7d 6e 18 09-1a ba 51 9e 70 35 ee 08   .;!.}n....Q.p5..
    00b0 - a1 47 80 f0 a3 d3 7f 7a-a5 46 c8 57 95 af a3 70   .G.....z.F.W...p
    00c0 - 2d ed c1 b6 8f 68 2f 5e-c4 b3 d8 71 79 15 ed 14   -....h/^...qy...
    00d0 - a2 35 a3 58 f8 d9 be 3d-bc 86 4d cf ba            .5.X...=..M..

    Start Time: 1600076632
    Timeout   : 300 (sec)
    Verify return code: 0 (ok)
---
DONE
```

From last 2 lines of above result, https cert is verified.
```
    Verify return code: 0 (ok)
```

### Verify with a local CA
```bash
$ echo "" | openssl s_client -CAfile ca.crt -connect www.example.net:443
CONNECTED(00000003)
depth=2 C = AE, O = Example, CN = ExampleRootCA
verify return:1
depth=1 C = AE, O = Example, CN = ExampleGlobalCA
verify return:1
depth=0 C = AE, O = Example, CN = www.example.net
verify return:1
---
Certificate chain
 0 s:/C=AE/O=Example/CN=www.example.net
   i:/C=AE/O=Example/CN=ExampleGlobalCA
---
Server certificate
-----BEGIN CERTIFICATE-----
MIIEqTCCA5GgAwIBAgIBHjANBgkqhkiG9w0BAQsFADA+MQswCQYDVQQGEwJBRTER
MA8GA1UECgwIRzQyQ2xvdWQxHDAaBgNVBAMME0c0MkNsb3VkUGJsR2xvYmFsQ0Ew
HhcNMjAwOTAxMDYwNTA3WhcNMjIwOTAyMDYwNTA3WjBFMQswCQYDVQQGEwJBRTER
MA8GA1UECgwIRzQyQ2xvdWQxIzAhBgNVBAMMGmdpdGxhYi5wdWJsaWMuZzQyY2xv
dWQubmV0MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAq/3Q0PjL3q83
j25Dnp45IilXZqx8eGArfR4OhqmMsxSzc383Lv3jFIP7L4YxOZ+7hOLJVJK7LIxW
MS7yWKYQBr2mBGeP2K0/DcuBZVTaW/cIWy0rTXTUnVF0KyIp9dNgeLWd4OXfRy/i
JoJw3/sA3F/IuxMfYY1mivFJWzaIgNsSsdhfVjLYM6rBMIXMMY4jad3oWlCH6S9K
cUPymgPQXjkie6l/C4C9LJCLch7P0zmjHV+xHnwKpRyjGovvG9861iybAmzAvPhU
EcCfQJu62YRImm6exJrY5slHOx6QImeHt64TN5So/LbN71cCVIRAsEsASl38UwWM
zbQvDQczbwIDAQABo4IBqTCCAaUwHwYDVR0jBBgwFoAUbAZfI1y16omwrTUCoUBD
R7LxJkUwgYsGCCsGAQUFBwEBBH8wfTAyBghrBgEFBQcwAYYmaHR0cDovL3BraS5w
dWJsaWMuZzQyY2xvdWQubmV0L2NhL29jc3AwRwYIKwYBBQUHMAKGO2h0dHA6Ly9w
a2kucHVibGljLmc0MmNsb3VkLm5ldC9pcGEvYWlhL0c0MkNsb3VkR2xvYmFsQ0Eu
Y3J0MA4GA1UdDwEB/wQEAwIE8DATBgNVHSUEDDAKBggrBgEFBQcDATCBiAYDVR0f
BIGAMH4wfKA4oDaGNGh0dHA6Ly9wa2kucHVibGljLmc0MmNsb3VkLm5ldC9pcGEv
Y3JsL01hc3RlckNSTC5iaW6iQKQ+MDwxCzAJBgNVBAYTAkFFMREwDwYDVQQKDAhH
NDJDbG91ZDEaMBgGA1UEAwwRRzQyQ2xvdWRQYmxSb290Q0EwHQYDVR0OBBYEFB8w
77o1BFCKbOgR4/TohlqP/u05MCUGA1UdEQQeMByCGmdpdGxhYi5wdWJsaWMuZzQy
Y2xvdWQubmV0MA0GCSqGSIb3DQEBCwUAA4IBAQCznjO2gULnENZiLR6nA26ak9gP
p1VpPZsIJGhQkt9MYnByu6Aa0kPLy+ekRfypsZoBlEXFlDNamwIOegzQLdcbcUv/
DfUhQqVh5YQbHzKbKdIs5MJXX0bILhJ81nX5eOzeNXEqwnyNEIp1ATWGZHTmX2I7
qwyLovUbchg3V/e+W/+WLgmwhQ0rFOXQrj8dvhUifTY6duZ0tNlf6ZOGiYjYbwt6
xBMMwQN++NWUYGpZPgNI9mc/cw+B13S20mPY/Q5rSfAfJxryPQt4IXWRu85kaUEo
EDXCfWfWO1Kr0ujOkrSYiiDP2FPgIqBuTembs0oFXBaLFoglfA8RYxMlDRo1
-----END CERTIFICATE-----
subject=/C=AE/O=Example/CN=www.example.net
issuer=/C=AE/O=Example/CN=ExampleGlobalCA
---
No client certificate CA names sent
Peer signing digest: SHA256
Server Temp Key: ECDH, P-256, 256 bits
---
SSL handshake has read 1867 bytes and written 427 bytes
---
New, TLSv1/SSLv3, Cipher is ECDHE-RSA-AES256-GCM-SHA384
Server public key is 2048 bit
Secure Renegotiation IS supported
Compression: NONE
Expansion: NONE
No ALPN negotiated
SSL-Session:
    Protocol  : TLSv1.2
    Cipher    : ECDHE-RSA-AES256-GCM-SHA384
    Session-ID: 4850A6EFD22B034368892FB9AA17C483C2C67C904F45DC66ED022278034D9554
    Session-ID-ctx:
    Master-Key: 54D878CDEC4ADE3C6FFBB1294044629F10E6773B99F258704C45A6BEA0C8B35C2A93F55C386D9DC2000F0F7380153425
    Key-Arg   : None
    Krb5 Principal: None
    PSK identity: None
    PSK identity hint: None
    TLS session ticket lifetime hint: 300 (seconds)
    TLS session ticket:
    0000 - cd bf 00 6a 5f 34 ca f9-c2 f8 9a d1 88 e0 53 38   ...j_4........S8
    0010 - 0e 9f 54 d3 c4 82 b6 f3-26 ce 79 e8 a9 56 89 aa   ..T.....&.y..V..
    0020 - e3 85 fe 01 07 e0 c0 cb-48 37 d6 42 07 ce a4 91   ........H7.B....
    0030 - 22 ef e3 48 34 22 5d f5-3f d2 5f 61 78 dd 52 e8   "..H4"].?._ax.R.
    0040 - 8b 68 75 1d 0a ed a3 89-64 7a 96 e0 4c f5 9d 88   .hu.....dz..L...
    0050 - 53 29 c9 cb eb a7 ba ab-f4 cb d3 a3 5f 4f cc 0f   S).........._O..
    0060 - cd fb 2a 91 34 48 0f d0-50 26 66 64 f0 08 eb fe   ..*.4H..P&fd....
    0070 - 76 cf fc cb bf d4 e6 2c-e8 a6 85 36 a9 29 75 71   v......,...6.)uq
    0080 - b8 6d d5 1d 81 c1 45 ba-08 9e 16 e9 dc 7e 2e ab   .m....E......~..
    0090 - e4 19 2e d4 67 6d 29 2f-f9 ce 1d b8 83 ba e9 80   ....gm)/........
    00a0 - 00 4f cd a1 ff 0d e1 4a-b8 0c 9a cc d5 90 64 30   .O.....J......d0

    Start Time: 1600083651
    Timeout   : 300 (sec)
    Verify return code: 0 (ok)
---
DONE
```

NOTE:
As shown in first lines of result:
```
depth=2 C = AE, O = Example, CN = ExampleRootCA
verify return:1
depth=1 C = AE, O = Example, CN = ExampleGlobalCA
verify return:1
depth=0 C = AE, O = Example, CN = www.example.net
verify return:1
```
site `www.example.net` cert was signed by `ExampleGlobalCA`. And `ExampleGlobalCA` was signed by `ExampleRootCA`. So that both public certs of `ExampleGlobalCA` and `ExampleRootCA` need to be combined in file `ca.crt`
```bash
$ cat ca.crt
$ cat /etc/docker/certs.d/registry.public.example.net/ca.crt
-----BEGIN CERTIFICATE-----
MIIDnzCCAoegAwIBAgIBATANBgkqhkiG9w0BAQsFADA8MQswCQYDVQQGEwJBRTER
MA8GA1UECgwIRzQyQ2xvdWQxGjAYBgNVBAMMEUc0MkNsb3VkUGJsUm9vdENBMB4X
DTIwMDgyNjEzMjgwMFoXDTQwMDgyNjEzMjgwMFowPDELMAkGA1UEBhMCQUUxETAP
BgNVBAoMCEc0MkNsb3VkMRowGAYDVQQDDBFHNDJDbG91ZFBibFJvb3RDQTCCASIw
DQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAL/yUWHxOBxuVql2CE2FYd5vKWov
VhV5yihl0yoDXTwTpWYAJIQcXF7LJa0hvpmrqx8OJWik8a7i+PVd+0c3hU9DYjLY
VPtMaRyFHfAKHX+pC1fUBMMhFVUFdJhG57XVMUq4twIMiwcZCiPwswkcV1Av3cIb
skOTNWdTBtlgU+82+QJhM+J6zamN1uMiGVVKn28asREP0/v3BoRGNT8b7urHwxAe
dwpi9a5mJeiFrGoyaZpXpOPBi4q3cXW2+R6bYR9oXnsFyRv7wqoKVZzmsvBiEzgo
7YxP4i4kk1ou8oTUub/+IYwVxzmJQq3CP1xOWgAU7eEfmuvNAUGBTZ6x6kUCAwEA
AaOBqzCBqDAfBgNVHSMEGDAWgBRA+68ZDOoJ3VwrA81FV8uReqtRfTAPBgNVHRMB
Af8EBTADAQH/MA4GA1UdDwEB/wQEAwIBxjAdBgNVHQ4EFgQUQPuvGQzqCd1cKwPN
RVfLkXqrUX0wRQYIKwYBBQUHAQEEOTA3MDUGCCsGAQUFBzABhilodHRwOi8vaXBh
LWNhLnB1YmxpYy5nNDJjbG91ZC5uZXQvY2Evb2NzcDANBgkqhkiG9w0BAQsFAAOC
AQEArGil4fCCIR3Bo52kxxwytNDnDZTYWpihQkmoZYINrbAaiWBljQ0rde3e5s5T
Kbv4I8R2WaSTbEA7pq0Qic0CUR81oCBRJGNuZ1XLACEJcYsyZjhrr+vLXgtFFrZm
tWRhFnen89K7VW6MvY9Kj2MRAg0jBMYRoT/RveXHlUud3nM+Aycip6KdZozZJKug
moY11oInpKMvh4Ru5bC1rsMPRT9zdIWgzRUj4IkvLdKojon0Mki1cLePsba4phmq
o+vmiwO8LGHnwbF30+PC43l09/mxqrKv4rYtVGy4tw++gbvIzfHGX78JZaG4EiKe
X5q34YkTvj6tHdAnOJ8uBd3yqA==
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
MIIDoTCCAomgAwIBAgIBEzANBgkqhkiG9w0BAQsFADA8MQswCQYDVQQGEwJBRTER
MA8GA1UECgwIRzQyQ2xvdWQxGjAYBgNVBAMMEUc0MkNsb3VkUGJsUm9vdENBMB4X
DTIwMDgyNjEzNTE1NVoXDTQwMDgyNjEzNTE1NVowPjELMAkGA1UEBhMCQUUxETAP
BgNVBAoMCEc0MkNsb3VkMRwwGgYDVQQDDBNHNDJDbG91ZFBibEdsb2JhbENBMIIB
IjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA17b3g8yJEy4GqVl0TfQMZI0a
8j+SSe/I8wD7/HiVSqSfIIGQI2LG4mrj5VZGLt+8o0UK6X4vUG8yJXrhTBYxZQKH
dOHkBlX5uU/hQfwQ0mzsGXJGXpSQUsZ2giJqUyWiHWVxa7aUTX4ANyXfQDtpwnCU
JDVWQUdu2hIPAOMisrcsLcGDlZD1wrop4Vjr6/qIRPLbi2nAQzsrVNWzcb+RUBrU
COCAu/+f5tchAM8biHFt3L6YdvWAPIMBh5mYwyhLEguvVBrKozvijDx7y1hj6ymZ
56NL74VMURsMaHK0mvdENmHV1h+CDoPc4JO6Lz6h40sDyP1jCjQ8QVsnnooCRQID
AQABo4GrMIGoMB8GA1UdIwQYMBaAFED7rxkM6gndXCsDzUVXy5F6q1F9MA8GA1Ud
EwEB/wQFMAMBAf8wDgYDVR0PAQH/BAQDAgHGMB0GA1UdDgQWBBRsBl8jXLXqibCt
NQKhQENHsvEmRTBFBggrBgEFBQcBAQQ5MDcwNQYIKwYBBQUHMAGGKWh0dHA6Ly9p
cGEtY2EucHVibGljLmc0MmNsb3VkLm5ldC9jYS9vY3NwMA0GCSqGSIb3DQEBCwUA
A4IBAQB278nz67UwR2XNwL07h4qeFUFjYlK9b8BUaafCIPsLndJ/La7RntAiN9Zc
KnMW4c2qzfhYx8Jz/YmzcZ3KVCFNYpgMSlFHQbxWjZzJXTnqfFxM7gSXpmkG09bc
3RCv6ixNLizPzFz40vZOzLFftLLcCUTpf+eFgmpeUSZ/Gi9uU98uBzWd+cCltY31
MHHCBUUHzokWRIvB9Veag57YbU3JKL9wf/k4XhSSM85ER5sXzyIx+LZvjWcgXNCX
mAlQmWiJmvpjqJOKvKJqVKu4vplS1NQr5RLsfINgYLFHyIWO3T5t+sEwP2zq2KP5
f+yM0bbrrPmdn6bOJcfdyNyaEIxa
-----END CERTIFICATE-----
```

### Install a new trusted CA Cert
```
$ sudo cp ca.crt /etc/pki/ca-trust/source/anchors/

$ sudo update-ca-trust
```


{% include links.html %}
