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

## split
* `-0`  
  Input items are splitted by `\0` instead of by whitespace. The GNU `find -print0` option produces input suitable for this mode.

* `-d delim`
  Input items are splitte by specified `delim`.  Multibyte characters are NOT supported. 

## batch
* `-n n`
  maximum `n` results after splitted will be in a batch, and every batch will be appended a '\n' during print
```bash
$ ls
a  b  c  d  logdir  one space.log  shdir  test  vmware-root

$ ls | xargs -d o | sed -ne 'l'
a$
b$
c$
d$
l gdir$
 ne space.l g$
shdir$
test$
vmware-r  t$
$

# batch 1:
# a 
# b
# c
# d
# lo
# batch 2:
# gdir
# o
# print result:
# a
# b
# c
# d
# l[o] gdir
# [o]\n

# batch 3:
# ne space.lo
# batch 4:
# g
# shdir
# test
# vmware-ro
# print result: 
# ne space.l[o]g
# shdir
# test
# vmware-r[o]\n

# batch 5:
# o
# batch 6:
# t
# print result: 
# [o]t\n

$ ls | xargs -d o -n 2 | sed -ne 'l'
a$
b$
c$
d$
l gdir$
$
ne space.l g$
shdir$
test$
vmware-r$
 t$
$
```

* `-L n`  
  maximum `n` lines after splitted will be in a batch   

## send
* `-i`    
  replace occurrences of `{}` with batch sent
```bash
$ find . -type f -name abc | xargs -i ls -al {} {}
-rw-rw-r-- 1 jun_zou jun_zou 0 Mar  4 20:20 ./abc
-rw-rw-r-- 1 jun_zou jun_zou 0 Mar  4 20:20 ./abc
```

* `-I replace-str`
  replace occurrences of `replace-str` with batch sent, and `replace-str`
```bash
$ find . -type f -name abc | xargs -I arg ls -al arg arg
-rw-rw-r-- 1 jun_zou jun_zou 0 Mar  4 20:20 ./abc
-rw-rw-r-- 1 jun_zou jun_zou 0 Mar  4 20:20 ./abc
```

## misc
* `-t`
  Print the command line on stderr before executing it

* `-p` 
  interactive run mode

* `-P max-procs`
  parrellel run `max-procs` processes; the default is 1