---
title: Ansible Tips
tags: [misc]
keywords: ansible, automation
last_updated: Dev 24, 2019
summary: "ansible playbook tips"
sidebar: mydoc_sidebar
permalink: misc_ansible_tips.html
folder: Misc
---

## Ansible Tips
=====

### group_by

group hosts via module [group_by](https://docs.ansible.com/ansible/latest/modules/group_by_module.html) dynamically by conditions


```bash
$ cat ilo_subnet.yml
---
- hosts: *
  gather_facts: false

  tasks:
  - name: check hw type
    shell: dmidecode -t system | awk -F':' '/Manufacturer/{print $NF}'
    register: hw_type

  - group_by:
      key: baremetal
    when: '"HP" in hw_type.stdout'

- hosts: baremetal
  gather_facts: false

  tasks:
  - name: get ilo subnet
    shell: ipmitool lan print  | awk -F':' '/Subnet/{print $NF}'
    register: ilo_subnet

  - group_by:
      key: ilo_wrong_subnet
    when: '"255.255.255" in ilo_subnet.stdout'

- hosts: ilo_wrong_subnet
  gather_facts: false

  tasks:
  - name: copy ilo change template to target
    copy:
      src: /tmp/ilosubnet.xml
      dest: /tmp/ilosubnet.xml
      mode: 0644

  - name: apply ilo change on taget
    shell: /usr/sbin/hponcfg -f /tmp/ilosubnet.xml

```

{% include links.html %}
