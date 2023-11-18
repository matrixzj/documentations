---
title: SSh Break Out While-Loop
tags: [bash]
keywords: bash, ssh
last_updated: May 28, 2020
summary: "Bash While-loop will be breaked by SSH"
sidebar: mydoc_sidebar
permalink: bash_ssh_break_out_of_while_loop.html
folder: bash
---

# SSh Break Out While-Loop
=====

## Issue
```bash
$ cat sn_verify1.sh
#!/bin/bash

line=$1

server=$(echo ${line} | awk '{print $1}')
local_sn=$(echo ${line} | awk '{print $2}' )

remote_sn_temp=$(ssh ${server} -q "dmidecode -t system | sed -ne '/Serial Number/s/.*: //p'")
remote_sn=${remote_sn_temp%% *}

echo ${server}
if [[ ${local_sn} == ${remote_sn} ]]; then echo same; else echo mismatch; fi

$ cat /tmp/sorted_test
test001.exmple.net CZJ14113TT
test002.exmple.net CZJ14113PM

$ while read -r line ; do ./sn_verify1.sh "${line}"; done < /tmp/sorted_test
test001.exmple.net
same
```

## Root cause
`ssh` reads from standard input, therefore it eats all remaining lines. We can just connect its standard input to nowhere
```bash
#!/bin/bash

line=$1

server=$(echo ${line} | awk '{print $1}')
local_sn=$(echo ${line} | awk '{print $2}' )

remote_sn_temp=$(cat /dev/null | ssh ${server} -q "dmidecode -t system | sed -ne '/Serial Number/s/.*: //p'" )
remote_sn=${remote_sn_temp%% *}

echo ${server}
if [[ ${local_sn} == ${remote_sn} ]]; then echo same; else echo mismatch; fi

$ while read -r line ; do ./sn_verify1.sh "${line}"; done < /tmp/sorted_test
test001.exmple.net
same
test002.exmple.net
same
```

or apply `-n` option with `ssh`
```
-n      Redirects stdin from /dev/null (actually, prevents reading from stdin).  This must be used when ssh is run in the background. A common trick is to use this to run X11 programs on a remote machine. For example, ssh -n shadows.cs.hut.fi emacs & will start an emacs on shadows.cs.hut.fi, and the X11 connection will be automatically forwarded over an encrypted channel. The ssh program will be put in the background.  (This does not work if ssh needs to ask for a password or passphrase; see also the -f option.)
```

```bash
$ cat sn_verify1.sh
#!/bin/bash

line=$1

server=$(echo ${line} | awk '{print $1}')
local_sn=$(echo ${line} | awk '{print $2}' )

remote_sn_temp=$(ssh ${server} -qn "dmidecode -t system | sed -ne '/Serial Number/s/.*: //p'" )
remote_sn=${remote_sn_temp%% *}

echo ${server}
if [[ ${local_sn} == ${remote_sn} ]]; then echo same; else echo mismatch; fi

$ while read -r line ; do  ./sn_verify1.sh "${line}"; done < /tmp/sorted_test
test001.exmple.net
same
test002.exmple.net
same
```

{% include links.html %}
