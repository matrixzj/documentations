---
title: Bash CheatSheet
tags: [bash]
keywords: bash, script
last_updated: April 25, 2020
summary: "Bash Script cheatsheet"
sidebar: mydoc_sidebar
permalink: bash_cheatsheet.html
folder: bash
---

## Bash Cheatsheet
=====

### Variables
```bash
$ NAME="Matrix"

$ echo $NAME
Matrix

$ echo "$NAME"
Matrix

$ echo "${NAME}"
Matrix
```

### String quotes
```bash
$ NAME="Matrix"

$ echo "Hi $NAME"
Hi Matrix

$ echo 'Hi $NAME'
Hi $NAME
```

### Shell Execution
```bash
$ echo "I'm in $(pwd)"
I'm in /home/Matrix/documentations

$ echo "I'm in `pwd`"
I'm in /home/Matrix/documentations
```
[Command Substitution](http://wiki.bash-hackers.org/syntax/expansion/cmdsubst)

### Functions
```bash
get_name() {
   echo "Matrix"
}

$ echo "You are $(get_name)"
You are Matrix
```



{% include links.html %}
