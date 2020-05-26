---
title: Python Ansible Filter Plugins
tags: [python]
keywords: python, ansible, filter, plugins
last_updated: May 26, 2020
summary: "Example to demostrate Ansible filter plugin" 
sidebar: mydoc_sidebar
permalink: python_ansible_filter_plugins.html
folder: python
---


## Ansible Filter Plugins
=====


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
    msg: "{{ 'test' | a_filter }}"
```

### result 
```
$ ansible-playbook tasks/test1.yml

PLAY [localhost] ***********************************************************************************************

TASK [Print a message] *****************************************************************************************
ok: [localhost] => {
    "msg": "test CRAZY NEW FILTER"
}

PLAY RECAP *****************************************************************************************************
localhost              : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

```

{% include links.html %}
