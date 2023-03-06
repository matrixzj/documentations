---
title: find
tags: [bash]
keywords: find 
last_updated: Mar 6, 2023
summary: "find howto"
sidebar: mydoc_sidebar
permalink: bash_find.html
folder: bash
---

# find
=====

## Format
```bash
find [-H] [-L] [-P] [-D debugopts] [-Olevel] [path...] [expression]
```

## Options
`-P`    Never follow symbolic links. Default Behaviors.   
`-L`    Follow symbolic links.   
`-H`    Don't follow symbolic links unless it was specified in `path`  

### Examples
```bash
$ ls -al
total 0
drwxrwxr-x   5 matrix matrix 157 Mar  5 07:40 .
drwxrwxrwt. 10 root    root    197 Mar  5 07:40 ..
-rw-rw-r--   1 matrix matrix   0 Mar  4 20:20 abc
-rw-rw-r--   1 matrix matrix   0 Mar  4 20:20 about.html
-rw-rw-r--   1 matrix matrix   0 Mar  4 20:20 a.log
-rw-rw-r--   1 matrix matrix   0 Mar  4 20:20 a.txt
-rw-rw-r--   1 matrix matrix   0 Mar  4 20:20 axyz.log
-rw-rw-r--   1 matrix matrix   0 Mar  4 20:26 b.html
lrwxrwxrwx   1 matrix matrix   4 Mar  5 07:40 etc -> /etc
lrwxrwxrwx   1 matrix matrix  10 Mar  5 07:36 hosts -> /etc/hosts
drwxrwxr-x   2 matrix matrix  19 Mar  4 20:21 testdir
drwxrwxr-x   2 matrix matrix   6 Mar  4 20:31 testdir1
drwxrwxr-x   2 matrix matrix  22 Mar  4 20:21 xyz

$ find . -name "host*" 2>/dev/null
./hosts

$ find -H . -path './etc/*' -name 'host*' 2>/dev/null | wc -l
0

$ find -H ./etc -path './etc/*' -name 'host*'  2>/dev/null
./etc/host.conf
./etc/hosts
./etc/hosts.allow
./etc/hosts.deny
./etc/cloud/templates/hosts.debian.tmpl
./etc/cloud/templates/hosts.freebsd.tmpl
./etc/cloud/templates/hosts.redhat.tmpl
./etc/cloud/templates/hosts.suse.tmpl
./etc/hostname

$ find -L etc -path 'etc/*' -name 'host*'  2>/dev/null
etc/host.conf
etc/hosts
etc/hosts.allow
etc/hosts.deny
etc/cloud/templates/hosts.debian.tmpl
etc/cloud/templates/hosts.freebsd.tmpl
etc/cloud/templates/hosts.redhat.tmpl
etc/cloud/templates/hosts.suse.tmpl
etc/hostname
```

`-D`    debugoptions   
    `rates`     Prints a summary indicating how often each predicate succeeded or failed   
    
`-O`   enable query optimisation
    
`-regextype type`  
    available options: `emacs`(default), `posix-awk`,  `posix-basic`,  `posix-egrep` and `posix-              extended`

## Expressions
made up of 
* `options` affect overall operation rather than the processing of a specific file, and always return true
* `tests`   return a true or false value
* `actions` have side effects and return a true or false value
and all expressions are connected with `operators`

### `Operators`
Listed in order of decreasing precedence:  
| Operators | Explanations |  
| :------ | :------ |  
| ( expr ) | Force precedence. Always need escape with `\`,  use '\(...\)' instead of '(...)' |  
| ! expr / -not expr | True if expr is false |  
| expr1 expr2 / expr1 -a expr2 / expr1 -and expr2 | "and"; expr2 is not evaluated if expr1 is false |  
| expr1 -o expr2 / expr1 -or expr2 | "or"; expr2 is not evaluated if expr1 is true |  
| expr1 , expr2 | List; both expr1 and expr2 are always evaluated. The value of expr1 is discarded; the value of the list is the value of expr2 |

### `options`
* `-daystart`  
  Measure time from the beginning of today rather than from 24 hours ago
    
* `-depth`  
  Process each directory's contents before the directory 
   
* `-maxdepth level`  
  Search only at most `level` (a non-negative integer) levels
    
* `-mindepth level`  
  Not apply any tests or actions at levels less than `level` (a non-negative integer). `1` means that all files except the command line arguments

```bash
$ date
Sun Mar  5 19:20:25 UTC 2023

$ stat -c'%y %n' /tmp/find/abc
2023-03-04 20:20:40.991547101 +0000 /tmp/find/abc

$ find /tmp/find -daystart -type f -atime -1 -name 'abc' | wc -l
0

$ find /tmp/find  -type f -atime -1 -name 'abc'
/tmp/find/abc
```

### `tests`
#### Match time
* `-amin n` / `-cmin n` / `-mmin n`
* `-atime n` / `-ctime n` / `-mtime n` (Unit: days)
* `-anewer file` / `-cnewer file` / `-newer file` 
* `-newerat TIME` / `-newerct TIME` / `-newermt TIME` 

```bash
$ stat -c'%y %n' b.html
2023-03-04 20:26:55.897968386 +0000 b.html

$ find . -type f -newerct '2023-03-04 20:25:00 +0000'
./b.html
```

#### Match file name
* `-iname pattern`  
  match filename (without path) in case insensitive

* `-path pattern` / `-ipath pattern`
  match filename (with path) 

* `-regex pattern` / `-iregex pattern`
  match regular expression `pattern`

#### Match permissions / owner / group
* `-perm mode`   
  exactly match `mode`

* `-perm -mode`
  All of the permission `bits` of `mode` are set 

* `-perm /mode`
  Any of the permission `bits` of `mode` are set 

```bash
# 640 = 000 110 100 000
$ find . -perm /640 -name a.txt
./a.txt

$ stat -c %a a.txt
400
# 400 = 000 100 000 000
```
  
* `-readable` / `-writable` / `executable`

* `-uid n` / `-user uname`

* `-gid n` / `-group gname`

* `-nogroup` / `-nouser`   
  match `group` or `owner` unable to map to any name

#### Misc
* `-false`  
  
* `-true`

### actions
* `-print`
  print all matching files / dirs with full relative path, and it is default action if no action was specified

* `-printf`
  print all matching files / dirs with specified format

* `-print0`
  print all matching files / dirs ended with '\0'

* `-delete`

* `-exec command \;`

* `-ok command \;` 
  interactively run `command` for all matching files / dirs 

* `-prune`
  if matching is dir, skip it. If `-depth` used, matching `dir` will not be skipped as contents of `dir` will be processed firstly. 

```bash
$ find . -name 'a.log'
./a.log
./testdir/a.log

$ find .  -path './testdir' -prune ! -name 'testdir' -o -name 'a.log'
./a.log

$ find . -depth -path './testdir' -prune ! -name 'testdir' -o -name 'a.log'
./a.log
./testdir/a.log

 $ find . -depth -path './testdir' -prune -o -name 'a.log'
./a.log
./testdir/a.log
./testdir
```