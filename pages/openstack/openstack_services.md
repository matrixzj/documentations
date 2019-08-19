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
:------:|:------:|:------:|:------:|:------:  
Identity service public endpoint | /etc/httpd/conf.d/wsgi-keystone.conf | 5000 | | publicurl  
Identity service (keystone) administrative endpoint | /etc/httpd/conf.d/wsgi-keystone.conf | 35357 | | adminurl
{: .table-bordered }


Compute API (nova-api) | /usr/lib/systemd/system/openstack-nova-api.service | 8773/8774, 8775 | openstack-nova-api.service
Compute VNC proxy for browsers ( openstack-nova-novncproxy) | /usr/lib/systemd/system/openstack-nova-novncproxy.service | 6080 | openstack-nova-novncproxy.service

Block Storage (cinder) 	8776 	publicurl and adminurl
Compute ports for access to virtual machine consoles 	5900-5999 	
Image service (glance) API 	9292 	publicurl and adminurl
Image service registry 	9191 	
Networking (neutron) 	9696 	publicurl and adminurl
Object Storage (swift) 	6000, 6001, 6002 	
Orchestration (heat) endpoint 	8004 	publicurl and adminurl
Orchestration AWS CloudFormation-compatible API (openstack-heat-api-cfn) 	8000 	
Orchestration AWS CloudWatch-compatible API (openstack-heat-api-cloudwatch) 	8003 	
Telemetry (ceilometer) 	8777 	publicurl and adminurl

{% include links.html %}
