---
title: Pure Bash Bible - Strings
tags: [bash]
keywords: bash, strings
last_updated: June 2, 2020
summary: "Pure Bash Bible Strings"
sidebar: mydoc_sidebar
permalink: bash_pure_bible_strings.html
folder: bash
---

# Pure Bash Bible - Strings
=====

## Trim leading and trailing white-space from string

### Function
```bash
trim_string() {
    # Usage: trim_string "   example   string    "
    : "${1#"${1%%[![:space:]]*}"}"
	# [![:space:]]* 	-> string from the first non-space charactor to the end 
	# "${1%%[![:space:]]*}" -> remove above string from the end, remaining is space prefix
	#
	# string="        matrix is nice      "
	#
	# $ string1="${string%%[![:space:]]*}"
	#
    # $ echo ${#string1}
    # 8
	#
	# "${1#"${1%%[![:space:]]*}"}" -> remove space prefix from the start	
	#
    # $ string2="${string#${string1}}"
    # 
    # $ echo "${string2}"
    # matrix is nice
    # 
    # $ echo "${#string2}"
    # 20
	# 
    : "${_%"${_##*[![:space:]]}"}"
	# 
    printf '%s\n' "$_"
}
```

### Example
```bash
$ trim_string "        matrix is nice      "
matrix is nice
```



{% include links.html %}
