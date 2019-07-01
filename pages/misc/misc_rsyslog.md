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

## Rsyslog
======

### Severity

Numerical Code|Severity|Description
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

### Troubleshoot Rsyslog with template `RSYSLOG_DebugFormat`

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
