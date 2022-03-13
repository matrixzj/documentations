---
title: KVM Migration Without Shared Storage
tags: [openstack]
keywords: vm, live migration
last_updated: Feb 24, 2020
summary: "VM live migration w/o shared storage"
sidebar: mydoc_sidebar
permalink: kvm_migration_without_shared_storage.html
folder: openstack
---


# KVM Live Migration without Shared Storage
=====

##  Prerequisite
### CPU Compatibility
VM CPU Model/Features must be compatible between source hypervisor and destination hypervisor. Determine CPU capability for hypervisor.
```
# virsh domcapabilities
<domainCapabilities>
  <path>/usr/libexec/qemu-kvm</path>
  <domain>kvm</domain>
  <machine>pc-i440fx-rhel7.6.0</machine>
  <arch>x86_64</arch>
  <vcpu max='240'/>
  <iothreads supported='yes'/>
  <os supported='yes'>
    <loader supported='yes'>
      <enum name='type'>
        <value>rom</value>
        <value>pflash</value>
      </enum>
      <enum name='readonly'>
        <value>yes</value>
        <value>no</value>
      </enum>
    </loader>
  </os>
  <cpu>
    <mode name='host-passthrough' supported='yes'/>
    <mode name='host-model' supported='yes'>
      <model fallback='forbid'>Skylake-Server-IBRS</model>
      <vendor>Intel</vendor>
      <feature policy='require' name='ss'/>
      <feature policy='require' name='hypervisor'/>
      <feature policy='require' name='tsc_adjust'/>
      <feature policy='require' name='clflushopt'/>
      <feature policy='require' name='pku'/>
      <feature policy='require' name='avx512vnni'/>
      <feature policy='require' name='stibp'/>
      <feature policy='require' name='ssbd'/>
      <feature policy='require' name='invtsc'/>
    </mode>
    ...
</domainCapabilities>
```
More info about CPU compatibility, Please refer to [CPU Model Config Doc](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html-single/virtualization_deployment_and_administration_guide/index#sect-Managing_guest_virtual_machines_with_virsh-Guest_virtual_machine_CPU_model_configuration)

### Replace `qemu-kvm` with more powerful `qemu-kvm-ev` emulator 
`qemu-kvm-ev` rpm for CentOS/RHEL7 is available [here](http://mirror.centos.org/centos/7/virt/x86_64/kvm-common/)

##  Migration Steps
### Create same storage pool in destination hypervisor
```
# virsh pool-define-as images --type dir --target /export/data/kvm/images/
 
# virsh pool-autostart images
Pool images marked as autostarted
 
# virsh pool-start images
 
# virsh pool-list
 Name                 State      Autostart
-------------------------------------------
 images               active     yes
```

### Create storage image file 
Before migration if image file format is configured as qcow2 and thin-provision. Otherwise, it will be copied as a raw / pre-allocation image 
```
# qemu-img create -f qcow2 /export/data/kvm/images/test.img 20G
```

### Migrate CMD (migrate smtp01 from kvm01 to kvm02 via ssh auth)
```
# virsh migrate --live smtp01 qemu+ssh://kvm02/system --copy-storage-all --verbose
root@kvm02's password:
Migration: [100 %]
 
 
root@kvm02:~ · 06:08 AM Tue Jan 21 ·
!668 # virsh list
 Id    Name                           State
----------------------------------------------------
 11    smtp01                      running
```
`--copy-storage-all`        copy storage image files to dest hypervisor  
`--verbose`                 show migration progess  
`--persistent`             create VM define XML file  

{% include links.html %}
