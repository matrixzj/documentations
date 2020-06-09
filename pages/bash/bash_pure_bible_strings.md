---
title: Pure Bash Bible - Strings
tags: [bash]
keywords: bash, strings
last_updated: June 9, 2020
summary: "Pure Bash Bible Strings"
sidebar: mydoc_sidebar
permalink: bash_pure_bible_strings.html
folder: bash
---

# Pure Bash Bible - Strings
=====

## Trim leading and trailing white-space from string
This is an alternative to `sed`, `awk`, `perl` and other tools. The function below works by finding all leading and trailing white-space and removing it from the start and end of the string. The `:` built-in is used in place of a temporary variable.

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
This is an alternative to `sed`, `awk`, `perl` and other tools. The function below works by abusing word splitting to create a new string without leading/trailing white-space and with truncated spaces.

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
The result of `bash`'s regex matching can be used to replace `sed` for a large number of use-cases.

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

## Split a string on a delimiter
This is an alternative to `cut`, `awk` and other tools.

### Function
```bash
split() {
    # Usage: split "string" "delimiter"
    IFS=$'\n' read -d "" -ra arr <<< "${1//$2/$'\n'}"
    # "${1//$2/$'\n'}"      -> within $1, replace all $2 with $'\n'
    # read
    #   -d delim
    #       The first character of delim is used to terminate the input line, rather than newline.
    #   -r  Backslash  does not act as an escape character.  The backslash is considered to be part of the line.  In particular, a backslash-newline pair may not be used as a line continuation.
    #   -a aname
    #       The  words  are  assigned  to  sequential indices of the array variable aname, starting at 0. aname is unset before any new values are assigned.  Other name arguments are ignored.
 
    printf '%s\n' "${arr[@]}"
}
```

### Example
```bash
$ split "apple,oranges,pears,grapes" ","
apple
oranges
pears
grapes

$ split "1, 2, 3, 4, 5" ", "
1
2
3
4
5
```

## lowercase / uppercase change or revert

### Functions 
```bash
lower() {
    # Usage: lower "string"
    printf '%s\n' "${1,,}"
}

upper() {
    # Usage: upper "string"
    printf '%s\n' "${1^^}"
}

reverse_case() {
    # Usage: reverse_case "string"
    printf '%s\n' "${1~~}"
}
```

## Trim quotes from a string

### Function
```bash
trim_quotes() {
    # Usage: trim_quotes "string"
    : "${1//\'}"
    printf '%s\n' "${_//\"}"
}
```

### Example
```bash
$ var="'Hello', \"World\""

$ trim_quotese "${var}"
Hello, World
```

## Strip all instances of pattern from string

### Function
```bash
strip_all() {
    # Usage: strip_all "string" "pattern"
    printf '%s\n' "${1//$2}"
}
```

### Example
```bash
$ strip_all "The Quick Brown Fox" "[[:space:]]"
TheQuickBrownFox

$ strip_all "The Quick Brown Fox" "[aeiou]"
Th Qck Brwn Fx
```

## Percent-encode / decode a string

### Function
```bash
urlencode() {
    # Usage: urlencode "string"
    local LC_ALL=C
    for (( i = 0; i < ${#1}; i++ )); do
        : "${1:i:1}"
        # slice the `i`th character
        case "$_" in
            [a-zA-Z0-9.~_-])
                printf '%s' "$_"
            ;;

            *)
                printf '%%%02X' "'$_"
                # if the leading character is a single or double quote, the value is the  ASCII  value  of  the  following character.
            ;;
        esac
    done
    printf '\n'
}

urldecode() {
    # Usage: urldecode "string"
    : "${1//+/ }"
    # remove '+'
    printf '%b\n' "${_//%/\\x}"
    # replace '%' to '\x'
    # %b     causes  printf  to  expand backslash escape sequences in the corresponding argument (except that \c terminates output, backslashes in \', \", and \? are not removed, and octal escapes beginning with \0 may contain up to four digits).
}
```

### Example
```bash
$ urlencode "https://github.com/dylanaraps/pure-bash-bible"
https%3A%2F%2Fgithub.com%2Fdylanaraps%2Fpure-bash-bible

$ urldecode "https%3A%2F%2Fgithub.com%2Fdylanaraps%2Fpure-bash-bible"
https://github.com/dylanaraps/pure-bash-bible
```

## Check if string contains / starts / ends with a sub-string

### Function
```bash
## Contains
if [[ $var == *sub_string* ]]; then
    printf '%s\n' "sub_string is in var."
fi

# Inverse (substring not in string).
if [[ $var != *sub_string* ]]; then
    printf '%s\n' "sub_string is not in var."
fi

# This works for arrays too!
if [[ ${arr[*]} == *sub_string* ]]; then
    printf '%s\n' "sub_string is in array."
fi

## Starts
if [[ $var == sub_string* ]]; then
    printf '%s\n' "var starts with sub_string."
fi

# Inverse (var does not start with sub_string).
if [[ $var != sub_string* ]]; then
    printf '%s\n' "var does not start with sub_string."
fi

## Ends
if [[ $var == *sub_string ]]; then
    printf '%s\n' "var ends with sub_string."
fi

# Inverse (var does not end with sub_string).
if [[ $var != *sub_string ]]; then
    printf '%s\n' "var does not end with sub_string."
fi
```


{% include links.html %}
