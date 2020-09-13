---
title: Pure Bash Bible - File Handling
tags: [bash]
keywords: bash, file handling
last_updated: July 9, 2020
summary: "Pure Bash Bible File Handling"
sidebar: mydoc_sidebar
permalink: bash_pure_bible_file_handling.html
folder: bash
---

# Pure Bash Bible - File Handling
=====

## Read a file to a string
Alternative to the `cat` command

### Function
```bash 
$ filedata="$(<"file")"
```

### Example
```bash
$ cat update.sh
git add .
git status
git commit -m "content update"
git push

$ file_data="$(<"update.sh")"

$ echo "${file_data}"
git add . git status git commit -m "content update" git push
```

## Read a file to an array (by line)

### Function
```bash
# Bash <4 (discarding empty lines)
IFS=$'\n' read -d "" -ra file_data < "file"

# Bash <4 (preserving empty lines)
while read -r line; do
    file_data+=("$line")
done < "file"

# Bash 4+
mapfile -t file_data < "file"
# or 
readarray -t file_data < "file"
```

### Example
```bash
$ cat update.sh
git add .
git status
git commit -m "content update"
git push

$ mapfile -t file_data < "update.sh"

$ echo "${file_data[@]}"
git add . git status git commit -m "content update" git push

$ for i in "${file_data[@]}"; do echo $i; done
git add .
git status
git commit -m "content update"
git push
```


{% include links.html %}
