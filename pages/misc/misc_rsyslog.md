---
title: Rsyslog
tags: [misc]
keywords: rsyslog, template
last_updated: Jul 1, 2019
summary: "rsyslog related"
sidebar: mydoc_sidebar
permalink: misc_rsyslog.html
folder: Misc
---

# Rsyslog
======

## Severity

Numerical<br>Code|Severity|Description
:------|:------|:------
0|emerg|system is unusable
1|alert|action must be taken immediately
2|crit|critical conditions
3|error|error conditions
4|warning|warning conditions
5|notice|normal but significant condition
6|info|informational messages
7|debug|debug-level messages

[Rsyslog Gentoo Wiki](https://wiki.gentoo.org/wiki/Rsyslog)

## Facility

Numerical<br>Code|Facility|Description
:------|:------|:------
0|kern|kernel messages
1|user|user-level messages
2|mail|mail system
3|daemon|system daemons
4|auth|security/authorization messages
5|syslog|messages generated internally by syslogd
6|lpr|line printer subsystem
7|news|network news subsystem
8|uucp|UUCP subsystem
9|cron|clock daemon
10|security|security/authorization messages
11|ftp|FTP daemon
12|ntp|NTP subsystem
13|logaudit|log audit
14|logalert|log alert
15|clock|clock daemon (note 2)
16|local0|local use 0 (local0)
17|local1|local use 1 (local1)
18|local2|local use 2 (local2)
19|local3|local use 3 (local3)
20|local4|local use 4 (local4)
21|local5|local use 5 (local5)
22|local6|local use 6 (local6)
23|local7|local use 7 (local7)

## Selectors Overwrite (later one will overwrite precedings)

```bash
local5.none;local5.crit                                 /var/log/matrix1
```

Test CMD
```bash
# logger -p local5.crit test4

# logger -p local5.info test5
```

Result: `test4` will be loggered to `/var/log/matrix1`, but `test5` will not be.

## Troubleshoot Rsyslog property issue with template `RSYSLOG_DebugFormat`

[Definition](https://www.rsyslog.com/doc/v8-stable/configuration/templates.html)
```bash
template(name="RSYSLOG_DebugFormat" type="list") {
     constant(value="Debug line with all properties:\nFROMHOST: '")
     property(name="fromhost")
     constant(value="', fromhost-ip: '")
     property(name="fromhost-ip")
     constant(value="', HOSTNAME: '")
     property(name="hostname")
     constant(value="', PRI: '")
     property(name="pri")
     constant(value=",\nsyslogtag '")
     property(name="syslogtag")
     constant(value="', programname: '")
     property(name="programname")
     constant(value="', APP-NAME: '")
     property(name="app-name")
     constant(value="', PROCID: '")
     property(name="procid")
     constant(value="', MSGID: '")
     property(name="msgid")
     constant(value="',\nTIMESTAMP: '")
     property(name="timereported")
     constant(value="', STRUCTURED-DATA: '")
     property(name="structured-data")
     constant(value="',\nmsg: '")
     property(name="msg")
     constant(value="'\nescaped msg: '")
     property(name="msg" controlcharacters="drop")
     constant(value="'\ninputname: ")
     property(name="inputname")
     constant(value=" rawmsg: '")
     property(name="rawmsg")
     constant(value="'\n$!:")
     property(name="$!")
     constant(value="\n$.:")
     property(name="$.")
     constant(value="\n$/:")
     property(name="$/")
     constant(value="\n\n")
}
```

config example

```bash
*.info;mail.none;authpriv.none;cron.none                /var/log/messages;RSYSLOG_DebugFormat
```

Output
```
Debug line with all properties:
FROMHOST: 'pekdev102', fromhost-ip: '127.0.0.1', HOSTNAME: 'pekdev102', PRI: 30,
syslogtag 'systemd:', programname: 'systemd', APP-NAME: 'systemd', PROCID: '-', MSGID: '-',
TIMESTAMP: 'Jun 30 16:20:04', STRUCTURED-DATA: '-',
msg: 'Started Session 127 of user root.'
escaped msg: 'Started Session 127 of user root.'
inputname: imjournal rawmsg: 'Started Session 127 of user root.'
$!:{ "PRIORITY": "6", "_UID": "0", "_GID": "0", "_BOOT_ID": "df5d069579954f42a23e06f4dd52cf1f", "_MACHINE_ID": "45f86e4fc8f242a2a84bad00ad2b5f86", "SYSLOG_FACILITY": "3", "SYSLOG_IDENTIFIER": "systemd", "CODE_FILE": "src\/core\/job.c", "CODE_LINE": "773", "CODE_FUNCTION": "job_log_status_message", "MESSAGE_ID": "39f53479d3a045ac8e11786248231fbf", "RESULT": "done", "_TRANSPORT": "journal", "_PID": "1", "_COMM": "systemd", "_EXE": "\/usr\/lib\/systemd\/systemd", "_CAP_EFFECTIVE": "1fffffffff", "_SYSTEMD_CGROUP": "\/", "_CMDLINE": "\/usr\/lib\/systemd\/systemd --switched-root --system --deserialize 22", "_HOSTNAME": "pekdev102.dev.fwmrm.net", "UNIT": "session-127.scope", "MESSAGE": "Started Session 127 of user root.", "_SOURCE_REALTIME_TIMESTAMP": "1561911604279131" }
$.:
$/:
```

[RHEL7 Administration Guide Rsyslog Templates](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html-single/system_administrators_guide/index#s2-Templates)


{% include links.html %}
