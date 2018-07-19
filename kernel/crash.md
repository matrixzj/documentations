---
title: Crash Utilities
author: Matrix Zou
layout: post
tags: [ kernel ]
---

Crash Utilities
=====

This repository is intended to contain several utilities written to help work
with crash [0] for vmcore analysis.

[0] https://people.redhat.com/anderson/crash_whitepaper/

dm-target debugging
===================

Debugging dm-targets can be a non-trivial task. Here are some tools to help.

dm-target persistent names
===========================

Note that dm device numbers, ie, dm-13, are not persistent across reboots.
This does not mean that they cannot be, this is very system specific.
Persistent dm-names can be kept accross boots if DM_PERSISTENT_DEV_FLAG is
passed to the DM_DEV_CREATE_CMD, in this case the dm core code would
instantiate dm devices with DM_ANY_MINOR which means " give me the next
available minor number". This sequence can be seen in dm-ioctl.c:dev_create
function.

Currently DM_PERSISTENT_DEV_FLAG is not explicitly used on lvm2, userspace
tools set it only if the minor is set on the dm task created, for instance:

	lvcreate or lvchange --persistent y --major major --minor minor

Note that even if none of this is used a system *can* boot with the same
dm-target names ! So best is to just verify the dm-target and respective mount
point yourselves. How to do this is explained below.

Inspecting dm-target pending IO
===============================
