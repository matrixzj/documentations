---
title: CentOS vs Ubuntu on Package Management  
tags: [misc, centos, ubuntu]
keywords: misc, centos, ubuntu, yum, apt-get, rpm
last_updated: March 29, 2023
summary: "CentOS vs Ubuntu on Package Management"
sidebar: mydoc_sidebar
permalink: misc_centos_ubuntu_package_management.html
folder: Misc
---

# CentOS vs Ubuntu on Package Management
=====

| Functions | CentOS | Ubuntu |
| :------ | :------ | :------ | 
| Find which installed package provided file | rpm -qf ${file_path} | dpkg -S ${file_path} |
| List Installed Packages | rpm -qa | apt list \-\-installed |
| List all availabe version for a Package | yum list --showduplicates ${package_name} | apt-get madison ${package_name} |
| Find which package from repo provided file | yum whatprovides */jq | apt-file update && apt-file search --regexp '.*/jq$' |
| Uninstall a package | yum remove jq | apt remove jq |

{: .table-bordered }

{% include links.html %}

