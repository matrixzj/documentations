---
title: OpenStack Services
tags: [openstack]
keywords: openstack, services, daemon, health check
last_updated: August 22, 2019
summary: "How to check health status for OpenStack daemons"
sidebar: mydoc_sidebar
permalink: openstack_services.html
folder: openstack
---


# OpenStack Services
=====

Daemon Description | Config File | Ports | Service Name | Note  
:------|:------|:------:|:------|:------  
Identity service public endpoint | /etc/keystone/keystone.conf<br>/etc/httpd/conf.d/wsgi-keystone.conf | 5000 | | publicurl  
Identity service (keystone) administrative endpoint | /etc/keystone/keystone.conf<br>/etc/httpd/conf.d/wsgi-keystone.conf | 35357 | | adminurl
Image service registry | /etc/glance/glance-registry.conf | 9191 | openstack-glance-registry.service | 
Image service (glance) API | /etc/glance/glance-api.conf | 9292 | openstack-glance-api.service | publicurl and adminurl
Compute API (nova-api) | /etc/nova/nova.conf | 8773/8774, 8775 | openstack-nova-api.service
Compute VNC proxy for browsers ( openstack-nova-novncproxy) | /etc/nova/nova.conf | 6080 | openstack-nova-novncproxy.service
Compute for VM ( openstack-nova-compute) | /etc/nova/nova.conf | | openstack-nova-compute.service
Networking (neutron) | /etc/neutron/neutron.conf<br>/etc/neutron/plugin.ini | 9696 | neutron-server.service | publicurl and adminurl
Networking (neutron comput) | /etc/neutron/neutron.conf<br>/etc/neutron/plugins/ml2/linuxbridge_agent.ini | | neutron-linuxbridge-agent.service | 
Block Storage (cinder) | /etc/cinder/cinder.conf | 8776 | openstack-cinder-api.service | publicurl and adminurl
Message Broker (AMQP traffic) | | 5672 | rabbitmq-server.service | OpenStack Block Storage, Networking, Orchestration, and Compute
{: .table-bordered }

## Nova Status 

```
# nova service-list 
+-----+------------------+---------------------------+-----------+---------+-------+----------------------------+-----------------+
| Id  | Binary           | Host                      | Zone      | Status  | State | Updated_at                 | Disabled Reason |
+-----+------------------+---------------------------+-----------+---------+-------+----------------------------+-----------------+
| 3   | nova-conductor   | controller.example.net    | internal  | enabled | up    | 2019-08-22T07:17:48.000000 | -               |
| 27  | nova-consoleauth | controller.example.net    | internal  | enabled | up    | 2019-08-22T07:17:42.000000 | -               |
| 30  | nova-scheduler   | controller.example.net    | internal  | enabled | up    | 2019-08-22T07:17:44.000000 | -               |
| 126 | nova-compute     | nova01.example.net        | nova      | enabled | up    | 2019-08-22T07:17:42.000000 | -               |
| 150 | nova-console     | controller.example.net    | internal  | enabled | up    | 2019-08-22T07:17:47.000000 | -               |
| 153 | nova-compute     | nova02.example.net        | DEV-iSCSI | enabled | up    | 2019-08-22T07:17:44.000000 | -               |
```

## Neutron Status

```
# neutron agent-list
+--------------------------------------+--------------------+---------------------------+-------------------+-------+----------------+---------------------------+
| id                                   | agent_type         | host                      | availability_zone | alive | admin_state_up | binary                    |
+--------------------------------------+--------------------+---------------------------+-------------------+-------+----------------+---------------------------+
| 110607ef-c74e-496a-886e-db2cd0621305 | DHCP agent         | controller.example.net    | nova              | :-)   | True           | neutron-dhcp-agent        |
| 171e4fcd-8243-48a8-b814-3992cca4450c | Metadata agent     | controller.example.net    |                   | :-)   | True           | neutron-metadata-agent    |
| 4d4d3217-7d79-4da4-bdc1-5da396957ac1 | Linux bridge agent | nova01.example.net        |                   | :-)   | True           | neutron-linuxbridge-agent |
| ef31f498-bef3-47e0-9e8f-8e966723cb3d | Linux bridge agent | controller.example.net    |                   | :-)   | True           | neutron-linuxbridge-agent |
```

## Check VM Info

```
#  nova list --fields status,host,name,networks --all-tenants 
+--------------------------------------+---------+---------------------------+-------------------------------+--------------------------+
| ID                                   | Status  | Host                      | Name                          | Networks                 |
+--------------------------------------+---------+---------------------------+-------------------------------+--------------------------+
| 1e6d2d9d-93c8-4610-bf82-26590568a531 | SHUTOFF | nova01.example.net        | wiki-test                     | VLAN32=192.168.18.80  |
| 311f160f-eaf3-46f3-ba43-a79f94df9025 | SHUTOFF | nova02.example.net        | matrix-test                   | VLAN32=192.168.18.230 |
| 78954b57-9744-4e0c-8707-18329723179a | SHUTOFF | nova02.example.net        | elk-test                      | VLAN32=192.168.18.83  |
| d57d667b-88bd-4347-b098-adeedd3bbe5f | SHUTOFF | nova02.example.net        | eas-test                      | VLAN32=192.168.18.79  |
```

{% include links.html %}
