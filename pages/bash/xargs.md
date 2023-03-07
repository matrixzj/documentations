---
title: xargs
tags: [bash]
keywords: xargs 
last_updated: Mar 7, 2023
summary: "xargs howto"
sidebar: mydoc_sidebar
permalink: bash_xargs.html
folder: bash
---

# xargs
=====
`xargs` takes items from stdin, delimited by blanks / newlines, and executes the command (default `/bin/echo`) one or more times. Blank lines on the standard input are ignored.

Processing sequence for `xargs`:
* split 
* batch
* send to parameters of following cmd
