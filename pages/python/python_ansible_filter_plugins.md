---
title: Python Ansible Filter Plugins
tags: [python]
keywords: python, ansible, filter, plugins
last_updated: June 3, 2020
summary: "Example to demostrate Ansible filter plugin" 
sidebar: mydoc_sidebar
permalink: python_ansible_filter_plugins.html
folder: python
---


# Ansible Filter Plugins
=====


## How-to

### demo.py

```
$ cat plugins/filter/demo.py
#!/usr/bin/env python
#-*- coding: utf-8 -*-

class FilterModule(object):
    def filters(self):
        return {
            'a_filter': self.a_filter,
        }

    def a_filter(self, a_variable):
        a_new_variable = a_variable + ' CRAZY NEW FILTER'
        return a_new_variable
```

### ansible config `ansible.cfg`
```
$ cat ansible.cfg | grep filter
filter_plugins              = plugins/filter
```

### playbook

```bash
$ cat tasks/test1.yml
---
- hosts: localhost
  gather_facts: false

  tasks:
  - name: Print a message
    debug:
    msg: "\{\{ 'test' | a_filter \}\}"

```

### result 
```bash
$ ansible-playbook tasks/test1.yml

PLAY [localhost] ***********************************************************************************************

TASK [Print a message] *****************************************************************************************
ok: [localhost] => {
    "msg": "test CRAZY NEW FILTER"
}

PLAY RECAP *****************************************************************************************************
localhost              : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

## Examples

### A new Viariable
```bash
$ cat plugins/filter/demo.py
#!/usr/bin/env python
#-*- coding: utf-8 -*-

class FilterModule(object):
    def filters(self):
        return {
            'b_filter': self.b_filter
        }

    def b_filter(self, a_variable):
        a_new_variable = 'current_' + a_variable + '_ver'
        return a_new_variable

$ cat tasks/test1.yml
---
- hosts: localhost
  gather_facts: false

  tasks:
  - name: Print a message
    set_fact:
      hw: "\{\{ 'nic' | b_filter \}\}"
      current_nic_ver: "1.0"

  - name: print a message
    debug:
      msg: "\{\{ lookup('vars', hw) \}\}"

$ ansible-playbook tasks/test1.yml
PLAY [localhost] *********************************************************************************************

TASK [Print a message] ***************************************************************************************
ok: [localhost]

TASK [print a message] ***************************************************************************************
ok: [localhost] => {
    "msg": "1.0"
}

PLAY RECAP ***************************************************************************************************
localhost             : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

## Filter to check rpm installed with wrong distro
```bash
$ cat plugins/filter/rpm_distro_check.py
#!/usr/bin/env python
#-*- coding: utf-8 -*-

class FilterModule(object):
    def filters(self):
        return {
            'rpm_distro_check': self.rpm_distro_check,
        }

    def rpm_distro_check(self, rpm_list, distro):
        rpm_dict = {}
        if distro == 'CentOS':
            wrong_build_host = 'redhat.com'
        elif distro == 'RedHat':
            wrong_build_host = 'centos.org'

        for rpm in rpm_list['stdout_lines']:
            if wrong_build_host in rpm.split(' ')[1]:
                rpm_dict[rpm.split(' ')[0]] = rpm.split(' ')[1]
        return rpm_dict

$ cat tasks/verify_rpm_vendor.yml
---
- hosts: all
  gather_facts: true

  tasks:
  - name: list all installed rpm packages
    shell: for i in `rpm -qa`; do rpm -q --queryformat "%{name} %{buildhost}\n" $i; done
    register: rpm_listed

  - name: show
    debug:
      msg: "\{\{ rpm_listed | rpm_distro_check( ansible_distribution ) | length \}\}"
    when:  "rpm_listed | rpm_distro_check( ansible_distribution ) | length > 0"

$ ansible-playbook -i inventory/prod --limit test117* tasks/verify_rpm_vendor.yml

PLAY [all] ******************************************************************************************************************

TASK [Gathering Facts] ******************************************************************************************************
ok: [test117.example.net]

TASK [list all installed rpm packages] **************************************************************************************
changed: [test117.example.net]

TASK [show] *****************************************************************************************************************
ok: [test117.example.net] => {
    "msg": "21"
}

PLAY RECAP ******************************************************************************************************************
test117.example.net        : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

```

{% include links.html %}
