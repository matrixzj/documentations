---
title: OpenStack Services
tags: [openstack]
keywords: openstack, services, daemon, health check
last_updated: August 19, 2019
summary: "How to check health status for OpenStack daemons"
sidebar: mydoc_sidebar
permalink: openstack_services.html
folder: openstack
---


## OpenStack Services
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



{% include links.html %}
