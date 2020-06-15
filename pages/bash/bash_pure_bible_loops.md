---
title: Pure Bash Bible - Loops
tags: [bash]
keywords: bash, loop
last_updated: June 12, 2020
summary: "Pure Bash Bible Loops"
sidebar: mydoc_sidebar
permalink: bash_pure_bible_loops.html
folder: bash
---

# Pure Bash Bible - Loops
=====

## Loop over a range of numbers
Alternative to `seq`

### Function
```bash
# Loop from 0-100 (no variable support).
for i in {0..100}; do
    printf '%s\n' "$i"
done

# Loop from 0-VAR.
VAR=50
for ((i=0;i<=VAR;i++)); do
    printf '%s\n' "$i"
done
```

## Loop over file

### Function
```bash
$ cat bash_test.sh
#!/bin/bash

current_ifs="${IFS}"

IFS='\n'
while read -r line; do
    printf '%s\n' "${line}"
done < $1

IFS=$current_ifs
```

### Example
```bash
$ ./bash_test.sh bash_test.sh
#!/bin/bash

current_ifs="${IFS}"

IFS='\n'
while read -r line; do
    printf '%s\n' "${line}"
done < $1

IFS=$current_ifs
```

{% include links.html %}
