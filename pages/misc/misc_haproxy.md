---
title: HAProxy
tags: [misc]
keywords: haproxy, https
last_updated: April 12th, 2020
summary: "loadbalancer with haproxy"
sidebar: mydoc_sidebar
permalink: misc_haproxy.html
folder: Misc
---

# HAProxy
=====

## HTTP LoadBalancer
### HAProxy Config
```bash
# yum -y install haproxy

# diff -Nru /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.orig
--- /etc/haproxy/haproxy.cfg    2020-04-12 13:58:57.407392712 +0000
+++ /etc/haproxy/haproxy.cfg.orig       2020-04-11 13:23:32.326590418 +0000
@@ -60,20 +60,27 @@
 #---------------------------------------------------------------------
 # main frontend which proxys to the backends
 #---------------------------------------------------------------------
-frontend http
-bind 0.0.0.0:80
-default_backend http_back
+frontend  main *:5000
+    acl url_static       path_beg       -i /static /images /javascript /stylesheets
+    acl url_static       path_end       -i .jpg .gif .png .css .js
+
+    use_backend static          if url_static
+    default_backend             app

 #---------------------------------------------------------------------
 # static backend for serving up images, stylesheets and such
 #---------------------------------------------------------------------
+backend static
+    balance     roundrobin
+    server      static 127.0.0.1:4331 check

 #---------------------------------------------------------------------
 # round robin balancing between the various backends
 #---------------------------------------------------------------------
-backend http_back
+backend app
     balance     roundrobin
-    server  web1 192.168.0.107:80 check
-    server  web2 192.168.0.108:80 check
+    server  app1 127.0.0.1:5001 check
+    server  app2 127.0.0.1:5002 check
+    server  app3 127.0.0.1:5003 check
+    server  app4 127.0.0.1:5004 check

# systemctl restart haproxy
```

### Verify
```bash
# curl http://localhost
web1.example.com

# curl http://localhost
web2.example.com
```

## Forward Source IP

### HAProxy config
```bash
# diff -Nru /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.orig
--- /etc/haproxy/haproxy.cfg    2020-04-12 15:19:13.776177277 +0000
+++ /etc/haproxy/haproxy.cfg.orig       2020-04-11 13:23:32.326590418 +0000
@@ -60,21 +60,27 @@
 #---------------------------------------------------------------------
 # main frontend which proxys to the backends
 #---------------------------------------------------------------------
-frontend http
-# bind 0.0.0.0:443 ssl crt /etc/haproxy/haproxy.example.com.pem
-bind 0.0.0.0:80
-option forwardfor
-default_backend http_back
+frontend  main *:5000
+    acl url_static       path_beg       -i /static /images /javascript /stylesheets
+    acl url_static       path_end       -i .jpg .gif .png .css .js
+
+    use_backend static          if url_static
+    default_backend             app

 #---------------------------------------------------------------------
 # static backend for serving up images, stylesheets and such
 #---------------------------------------------------------------------
+backend static
+    balance     roundrobin
+    server      static 127.0.0.1:4331 check

 #---------------------------------------------------------------------
 # round robin balancing between the various backends
 #---------------------------------------------------------------------
-backend http_back
+backend app
     balance     roundrobin
-    server  web1 192.168.0.107:80 check
-    server  web2 192.168.0.108:80 check
+    server  app1 127.0.0.1:5001 check
+    server  app2 127.0.0.1:5002 check
+    server  app3 127.0.0.1:5003 check
+    server  app4 127.0.0.1:5004 check
```

### HTTP Cconfig
```bash
# diff -Nru /etc/httpd/conf/httpd.conf{,.orig}
--- /etc/httpd/conf/httpd.conf  2020-04-12 15:42:52.165901625 +0000
+++ /etc/httpd/conf/httpd.conf.orig     2020-04-12 15:42:45.405831713 +0000
@@ -193,8 +193,7 @@
     # The following directives define some format nicknames for use with
     # a CustomLog directive (see below).
     #
-    # LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
-    LogFormat "%{X-Forwarded-For}i %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
+    LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
     LogFormat "%h %l %u %t \"%r\" %>s %b" common
```

#### Verify 
```bash
client$ ip addr show eth0  | awk '/inet/{print $2}'
192.168.0.40/24

client$ ssh 192.168.0.48 "systemctl is-active haproxy; ip addr show eth0  | awk '/inet/{print \$2}'"
Warning: Permanently added '192.168.0.48' (ECDSA) to the list of known hosts.
active
192.168.0.48/24

client$ ssh 192.168.0.108 'tail -n 1 /var/log/httpd/access_log'
Warning: Permanently added '192.168.0.48' (ECDSA) to the list of known hosts.
192.168.0.40 - - [12/Apr/2020:15:49:17 +0000] "GET / HTTP/1.1" 200 19 "-" "curl/7.29.0"
```

## HTTP SSL offloading 

### SSL Cert 
NOTE: How to Generate Private key and Public Cert, please refer to [CA](idm_ca.html)
```bash
# cat haproxy.example.com.crt haproxy.example.com.key  > haproxy.example.com.pem

# cp haproxy.example.com.pem /etc/haproxy/
```

### HAProxy config
```bash
# diff -Nru /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.orig
--- /etc/haproxy/haproxy.cfg    2020-04-12 16:26:47.688222216 +0000
+++ /etc/haproxy/haproxy.cfg.orig       2020-04-11 13:23:32.326590418 +0000
@@ -60,20 +60,27 @@
 #---------------------------------------------------------------------
 # main frontend which proxys to the backends
 #---------------------------------------------------------------------
-frontend http
-bind 0.0.0.0:443 ssl crt /etc/haproxy/haproxy.example.com.pem
-option forwardfor
-default_backend http_back
+frontend  main *:5000
+    acl url_static       path_beg       -i /static /images /javascript /stylesheets
+    acl url_static       path_end       -i .jpg .gif .png .css .js
+
+    use_backend static          if url_static
+    default_backend             app

 #---------------------------------------------------------------------
 # static backend for serving up images, stylesheets and such
 #---------------------------------------------------------------------
+backend static
+    balance     roundrobin
+    server      static 127.0.0.1:4331 check

 #---------------------------------------------------------------------
 # round robin balancing between the various backends
 #---------------------------------------------------------------------
-backend http_back
+backend app
     balance     roundrobin
-    server  web1 192.168.0.107:80 check
-    server  web2 192.168.0.108:80 check
+    server  app1 127.0.0.1:5001 check
+    server  app2 127.0.0.1:5002 check
+    server  app3 127.0.0.1:5003 check
+    server  app4 127.0.0.1:5004 check

# systemctl restart haproxy
```

### Verify 
```bash
# curl -k https://localhost
web1.example.com

# curl -k https://localhost
web2.example.com
```

{% include links.html %}
