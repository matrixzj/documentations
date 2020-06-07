---
title: Pure Bash Bible - Strings
tags: [bash]
keywords: bash, strings
last_updated: June 7, 2020
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
    # [![:space:]]* 				-> string from the first non-space charactor to the end 
    # "${1%%[![:space:]]*}" 		-> greedly remove above string from the end, remaining is space prefix
    #
    # string="        matrix is nice      "
    #
    # $ string1="${string%%[![:space:]]*}"
    #
    # $ echo "${#string1}"
    # 8
    #
    # "${1#"${1%%[![:space:]]*}"}"	-> remove space prefix from the start	
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
    # *[![:space:]] 				-> string from start to the a non-space charactor, 'matrix is nice'
    # ${_##*[![:space:]]}			-> greedly remove above string from the start, remove 'matrix is nice' from the start, remaining is space suffix
    #
    # $ string3="${string2##*[![:space:]]}"
    #
    # $ echo "${#string3}"
    # 6
    #
    # "${_%"${_##*[![:space:]]}"}"	-> remove space suffix from the end
    #
    # $ string4="${string2%${string3}}"
    # 
    # $ echo "${#string4}"
    # 14
    # 
    # $ echo "${string4}"
    # matrix is nice

    printf '%s\n' "$_"
}
```

### Example
```bash
$ trim_string "        matrix is nice      "
matrix is nice
```

## Trim all white-space from string and truncate spaces
### Function
```bash
trim_all() {
    # Usage: trim_all "   example   string    "
    set -f
    # -f    noglob
    # Disable [pathname expansion (globbing)](https://wiki.bash-hackers.org/syntax/expansion/globs)
    set -- $*
    # --    If no arguments follow, the positional parameters are unset. With arguments, the positional parameters are set, even if the strings begin with a - (dash) like an option.
    printf '%s\n' "$*"
    set +f
}
```

### Example
```bash
$ trim_all "    matrix    is   nice    "
matrix is nice
```

## Use regex on a string
### Function
```bash
regex() {
    # Usage: regex "string" "regex"
    [[ $1 =~ $2 ]] && printf '%s\n' "${BASH_REMATCH[1]}"
}
```

### Example
```bash
# Trim leading white-space.
$ regex '    hello' '^\s*(.*)'
hello

# Validate a hex color.
$ regex "#FFFFFF" '^(#?([a-fA-F0-9]{6}|[a-fA-F0-9]{3}))$'
#FFFFFF

# Validate a hex color (invalid).
$ regex "red" '^(#?([a-fA-F0-9]{6}|[a-fA-F0-9]{3}))$'
# no output (invalid)

$ cat color_verify.sh
#!/bin/bash

$ is_hex_color() {
    if [[ $1 =~ ^(#?([a-fA-F0-9]{6}|[a-fA-F0-9]{3}))$ ]]; then
        printf '%s\n' "${BASH_REMATCH[1]}"
    else
        printf '%s\n' "error: $1 is an invalid color."
        return 1
    fi
}

read -r color
is_hex_color "$color" || color="#FFFFFF"

$ echo "#95968d" | ./color_verify.sh
#95968d

$ echo "red" | ./color_verify.sh
error: red is an invalid color.
```

{% include links.html %}
