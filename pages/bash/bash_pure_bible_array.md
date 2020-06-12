---
title: Pure Bash Bible - Array
tags: [bash]
keywords: bash, array
last_updated: June 12, 2020
summary: "Pure Bash Bible Array"
sidebar: mydoc_sidebar
permalink: bash_pure_bible_Array.html
folder: bash
---

# Pure Bash Bible - Array
=====

## Reverse an array

### Function
```bash
reverse_array() {
    # Usage: reverse_array "array"
    shopt -s extdebug
    # extdebug
    # ......
    #   4.     BASH_ARGC and BASH_ARGV are updated as described in their descriptions above.
    # ......
    f()(printf '%s\n' "${BASH_ARGV[@]}"); f "$@"
    # BASH_ARGV
    # An array variable containing all of the parameters in the current bash execution call stack. The final parameter of the last subroutine call is at the top of the stack; the first parameter of the initial call is at the bottom. 
    shopt -u extdebug
}
```

### Example
```bash
$ reverse_array 1 2 3 4 5
5
4
3
2
1

$ arr=(apple lemon grape)

$ reverse_array "${arr[@]}"
grape
lemon
apple
```

## Remove duplicate array elements
Create a temporary associative array. When setting associative array values and a duplicate assignment occurs, bash overwrites the key. This allows us to effectively remove array duplicates.

### Function
```bash
remove_array_dups() {
    # Usage: remove_array_dups "array"
    declare -A tmp_array
    # create a temporary dict

    for i in "$@"; do
        [[ $i ]] && IFS=" " tmp_array["${i:- }"]=1
        # [[ string ]]
        # [[ -n string ]]
        #      True if the length of string is non-zero.
        # For temporary dict 'tmp_array', use original array element as key, 1 as value to create new element. If key is duplicated with existed, it will be overwritten.  
    done

    printf '%s\n' "${!tmp_array[@]}"
    # Iteration on dict keys
}

### Example
```bash
$ remove_array_dups 1 1 2 2 1 1 3 3
1
2
3
```

## Random array element

### Function
```bash
random_array_element() {
    # Usage: random_array_element "array"
    local arr=("$@")
    printf '%s\n' "${arr[RANDOM % $#]}"
}
```

### Example
```bash
$ array=(red green blue yellow brown)

$ random_array_element "${array[@]}"
brown

$ random_array_element "${array[@]}"
red

$ random_array_element 1 2 3 4 5 6 7
5

$ random_array_element 1 2 3 4 5 6 7
6
```

## Cycle through an Array

### Function
```bash
cycle() {
    local arr=("$@")
    printf '%s ' "${arr[${i:=0}]}"
    ((i=i>=${#arr[@]}-1?0:++i))
    # if i>${#arr[@]}-1, i=0; else ++i
}
```

### Example
```bash
$ array=(a b c d)

$ cycle "${array[@]}"
a

$ cycle "${array[@]}"
b

$ cycle "${array[@]}"
c

$ cycle "${array[@]}"
d

$ cycle "${array[@]}"
a

$ arr=(true false)

$ cycle "${arr[@]}"
false

$ cycle "${arr[@]}"
true

$ cycle "${arr[@]}"
false
```

{% include links.html %}
