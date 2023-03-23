---
title: jq
tags: [misc]
keywords: json, jq
last_updated: Jul 14, 2022
summary: "parse json with jq"
sidebar: mydoc_sidebar
permalink: misc_jq.html
folder: Misc
---

- [jq](#jq)
  - [data](#data)
  - [Options](#options)
    - [`-S` sort keys](#-s-sort-keys)
    - [`-c` compact output](#-c-compact-output)
    - [`-f` read filter from file](#-f-read-filter-from-file)
    - [`--arg` / `--argjson` pass parameters from bash](#--arg----argjson-pass-parameters-from-bash)
    - [`--slrupfile` reads JSON from `file` and binds to a global variable](#--slrupfile-reads-json-from-file-and-binds-to-a-global-variable)
  - [Types and Values](#types-and-values)
    - [`..` Recursive Descent](#-recursive-descent)
  - [Built-in Functions](#built-in-functions)
    - [`length`](#length)
    - [`keys` / `keys_unsorted`](#keys--keys_unsorted)
    - [`has(key)`](#haskey)
    - [`map(x)` / `map_values(x)`](#mapx--map_valuesx)
    - [`path(path_expression)`](#pathpath_expression)
    - [`del(path_expression)`](#delpath_expression)
    - [`getpath(PATHS)`](#getpathpaths)
    - [`setpath(PATHS; VALUE)`](#setpathpaths-value)
    - [`to_entries`, `from_entries`, `with_entries`](#to_entries-from_entries-with_entries)
    - [`select(boolean_expression)`](#selectboolean_expression)
    - [`arrays`, `objects`, `iterables`, `booleans`, `numbers`, `normals`, `finites`, `strings`, `nulls`, `values`, `scalars`](#arrays-objects-iterables-booleans-numbers-normals-finites-strings-nulls-values-scalars)
    - [`paths`](#paths)
    - [`add`](#add)
    - [`any` / `all` / `any(condition)` / `all(condition)`](#any--all--anycondition--allcondition)
    - [`range(upto)` / `range(from; upto)` / `range(from; to; by)`](#rangeupto--rangefrom-upto--rangefrom-to-by)
    - [`tonumber` / `tostring`](#tonumber--tostring)
    - [`type`](#type)
    - [`sort` / `sort_by(path_expression)`](#sort--sort_bypath_expression)
    - [`group_by(path_expression)`](#group_bypath_expression)
    - [`min` / `max` / `min_by(path_exp)` / `max_by(path_exp)`](#min--max--min_bypath_exp--max_bypath_exp)
    - [`unique` / `unique_by(path_exp)`](#unique--unique_bypath_exp)
    - [`reverse`](#reverse)
    - [`contains(element)`](#containselement)
    - [`indices(s)`](#indicess)
    - [`index(s)` / `rindex(s)`](#indexs--rindexs)
    - [`inside(s)`](#insides)
    - [`startswith(str)` / `endswith(str)`](#startswithstr--endswithstr)
    - [`combinations` / `combinations(n)`](#combinations--combinationsn)
    - [`ltrimstr(str)` / `rtrimstr(str)`](#ltrimstrstr--rtrimstrstr)
    - [`explode` / `implode`](#explode--implode)
    - [`split(s)` / `join(s)`](#splits--joins)
    - [`ascii_upcase` / `ascii_downcase`](#ascii_upcase--ascii_downcase)
    - [`while(crondition; update)` / `until(crondition; next)`](#whilecrondition-update--untilcrondition-next)
  - [Examples](#examples)
    - [Show all keys](#show-all-keys)
    - [Show Specific Element by Index](#show-specific-element-by-index)
    - [Show Multi Attibutes](#show-multi-attibutes)
    - [Filter by value](#filter-by-value)
    - [Resharp json](#resharp-json)
    - [skip null iterator with `?`](#skip-null-iterator-with-)
    - [filter case insensitive with `"i"`](#filter-case-insensitive-with-i)
    - [filter value based on another is existed](#filter-value-based-on-another-is-existed)
    - [combine 2 values](#combine-2-values)
    - [resharp result as an array](#resharp-result-as-an-array)
    - [`split`](#split)
    - [get substring with `capture`](#get-substring-with-capture)


# jq
=====

## data
```
$ cat /tmp/data
{
    "Subnets": [
        {
            "AvailabilityZone": "us-east-1a",
            "Tags": [
                {
                    "Value": "DEV",
                    "Key": "Env"
                },
                {
                    "Value": "AccountBase",
                    "Key": "aws:cloudformation:stack-name"
                },
                {
                    "Value": "PrivateSubnet1a",
                    "Key": "aws:cloudformation:logical-id"
                },
                {
                    "Value": "Systems",
                    "Key": "Owner"
                },
                {
                    "Value": "PrivateSubnet1a",
                    "Key": "Name"
                }
            ],
            "AvailableIpAddressCount": 214,
            "DefaultForAz": false,
            "Ipv6CidrBlockAssociationSet": [],
            "State": "available",
            "MapPublicIpOnLaunch": false,
            "SubnetId": "subnet-xxxxxx",
            "CidrBlock": "10.1.2.0/24",
            "AssignIpv6AddressOnCreation": false
        },
        {
            "AvailabilityZone": "us-east-1a",
            "Tags": [
                {
                    "Value": "Systems",
                    "Key": "Owner"
                },
                {
                    "Value": "AccountBase",
                    "Key": "aws:cloudformation:stack-name"
                },
                {
                    "Value": "PublicSubnet1a",
                    "Key": "aws:cloudformation:logical-id"
                },
                {
                    "Value": "DEV",
                    "Key": "Env"
                }
            ],
            "AvailableIpAddressCount": 250,
            "DefaultForAz": false,
            "Ipv6CidrBlockAssociationSet": [],
            "State": "available",
            "MapPublicIpOnLaunch": false,
            "SubnetId": "subnet-yyyyyy",
            "CidrBlock": "10.1.0.0/24",
            "AssignIpv6AddressOnCreation": false
        }
    ]
}
```

## Options
### `-S` sort keys   
```bash
$ cat /tmp/jq-data | jq -r -S '.Subnets[0]'
{
  "AssignIpv6AddressOnCreation": false,
  "AvailabilityZone": "us-east-1a",
  "AvailableIpAddressCount": 214,
  "CidrBlock": "10.1.2.0/24",
  "DefaultForAz": false,
  "Ipv6CidrBlockAssociationSet": [],
  "MapPublicIpOnLaunch": false,
  "State": "available",
  "SubnetId": "subnet-xxxxxx",
  "Tags": [
    {
      "Key": "Env",
      "Value": "DEV"
    },
    {
      "Key": "aws:cloudformation:stack-name",
      "Value": "AccountBase"
    },
    {
      "Key": "aws:cloudformation:logical-id",
      "Value": "PrivateSubnet1a"
    },
    {
      "Key": "Owner",
      "Value": "Systems"
    },
    {
      "Key": "Name",
      "Value": "PrivateSubnet1a"
    }
  ]
}
```

### `-c` compact output  
```bash
$ cat /tmp/jq-data | jq -c
{"Subnets":[{"AvailabilityZone":"us-east-1a","Tags":[{"Value":"DEV","Key":"Env"},{"Value":"AccountBase","Key":"aws:cloudformation:stack-name"},{"Value":"PrivateSubnet1a","Key":"aws:cloudformation:logical-id"},{"Value":"Systems","Key":"Owner"},{"Value":"PrivateSubnet1a","Key":"Name"}],"AvailableIpAddressCount":214,"DefaultForAz":false,"Ipv6CidrBlockAssociationSet":[],"State":"available","MapPublicIpOnLaunch":false,"SubnetId":"subnet-xxxxxx","CidrBlock":"10.1.2.0/24","AssignIpv6AddressOnCreation":false},{"AvailabilityZone":"us-east-1a","Tags":[{"Value":"Systems","Key":"Owner"},{"Value":"AccountBase","Key":"aws:cloudformation:stack-name"},{"Value":"PublicSubnet1a","Key":"aws:cloudformation:logical-id"},{"Value":"DEV","Key":"Env"}],"AvailableIpAddressCount":250,"DefaultForAz":false,"Ipv6CidrBlockAssociationSet":[],"State":"available","MapPublicIpOnLaunch":false,"SubnetId":"subnet-yyyyyy","CidrBlock":"10.1.0.0/24","AssignIpv6AddressOnCreation":false}]}
```

### `-f` read filter from file   
```bash
$ cat /tmp/filter
.Subnets[].AvailabilityZone

$ cat /tmp/jq-data | jq -r -f /tmp/filter
us-east-1a
us-east-1a
```

### `--arg` / `--argjson` pass parameters from bash  
```bash
$ test_cidr='10.1.0.*'

$ jq -r --arg cidr "${test_cidr}" '.Subnets[] | {cidr: .CidrBlock} | select(.cidr | test($cidr))' /tmp/data
{
  "cidr": "10.1.0.0/24"
}
```

parameter as an integer
```bash
$ avaiable_ips_threshhold=220

$ jq -r --argjson ip_threshhold "${avaiable_ips_threshhold}" '.Subnets[] | {subnetid: .SubnetId, AvailableIp: .AvailableIpAddressCount} | select(.AvailableIp > $ip_threshhold)' /tmp/data
{
  "subnetid": "subnet-yyyyyy",
  "AvailableIp": 250
}

$ jq -r --arg ip_threshhold "${avaiable_ips_threshhold}" '.Subnets[] | {subnetid: .SubnetId, AvailableIp: .AvailableIpAddressCount} | select(.AvailableIp > ($ip_threshhold | tonumber))' /tmp/jq-data
{
  "subnetid": "subnet-yyyyyy",
  "AvailableIp": 250
}
```

### `--slrupfile` reads JSON from `file` and binds to a global variable   
```bash
$ cat /tmp/filter | jq .
{
  "avaiable_ips_threshhold": 220
}

$ jq -r --slurpfile var /tmp/filter '$var' /tmp/jq-data
[
  {
    "avaiable_ips_threshhold": 220
  }
]

$ jq -r --slurpfile var /tmp/filter '.Subnets[] | {subnetid: .SubnetId, AvailableIp: .AvailableIpAddressCount} | select(.AvailableIp > $var[0].avaiable_ips_threshhold)' /tmp/jq-data
{
  "subnetid": "subnet-yyyyyy",
  "AvailableIp": 250
}
```

## Types and Values
### `..` Recursive Descent 

## Built-in Functions
### `length` 
gets the length of various different types of value
```bash
$ cat /tmp/data | jq '.Subnets | length'
2
```

Count elements based on some specifict conditions
```bash
$ jq -r '.Subnets[] | select(.State == "available") | length' /tmp/data
10
10

$ jq -r '[.Subnets[] | select(.State == "available")] | length' /tmp/data
2
```

### `keys` / `keys_unsorted` 
returns its keys in an array
```bash
$ cat /tmp/data | jq '. | keys[]'
"Subnets"

$ cat /tmp/data | jq '.Subnets[0] | keys_unsorted '
[
  "AvailabilityZone",
  "Tags",
  "AvailableIpAddressCount",
  "DefaultForAz",
  "Ipv6CidrBlockAssociationSet",
  "State",
  "MapPublicIpOnLaunch",
  "SubnetId",
  "CidrBlock",
  "AssignIpv6AddressOnCreation"
]

$ cat /tmp/data | jq '.Subnets | keys[]'
0
1
```

### `has(key)` 
returns whether the input object has the given key / `in` returns the input key is in the given object, or the input index corresponds to an element in the given array
```bash
$ cat /tmp/data | jq 'has("Subnets")'
true

$ cat /tmp/data | jq '. | keys[] | in({"Subnets": 1})'
true

$ cat /tmp/data | jq '.Subnets | keys[]'
0
1

$ cat /tmp/data | jq '[2] | keys[]'
0

$ cat /tmp/data | jq '.Subnets | keys[] | in([2])'
true
false

# given array '[2]' has only one index: 0
```

### `map(x)` / `map_values(x)` 
apply filter `x` to each element of the input array
```bash
$ cat /tmp/data | jq '.Subnets | keys'
[
  0,
  1
]

$ cat /tmp/data | jq '.Subnets | keys | map(.+1)'
[
  1,
  2
]
```

### `path(path_expression)` 
returns array representations of the given path expression in `.`. The outputs are arrays of strings (object keys) and/or numbers (array indices).
```bash
$ cat /tmp/data | jq '.Subnets[0].SubnetId'
"subnet-xxxxxx"

$ cat /tmp/data | jq 'path(.Subnets[0].SubnetId)'
[
  "Subnets",
  0,
  "SubnetId"
]
```

### `del(path_expression)` 
removes a key and its corresponding value 
```bash
$ cat /tmp/data | jq '.Subnets[] | del(.Tags)'
{
  "AvailabilityZone": "us-east-1a",
  "AvailableIpAddressCount": 214,
  "DefaultForAz": false,
  "Ipv6CidrBlockAssociationSet": [],
  "State": "available",
  "MapPublicIpOnLaunch": false,
  "SubnetId": "subnet-xxxxxx",
  "CidrBlock": "10.1.2.0/24",
  "AssignIpv6AddressOnCreation": false
}
{
  "AvailabilityZone": "us-east-1a",
  "AvailableIpAddressCount": 250,
  "DefaultForAz": false,
  "Ipv6CidrBlockAssociationSet": [],
  "State": "available",
  "MapPublicIpOnLaunch": false,
  "SubnetId": "subnet-yyyyyy",
  "CidrBlock": "10.1.0.0/24",
  "AssignIpv6AddressOnCreation": false
}
```

### `getpath(PATHS)` 
returns the values in of each `PATHS`.
```bash
$ cat /tmp/data| jq 'getpath(["Subnets", 0, "AvailableIpAddressCount"], ["Subnets", 1, "AvailableIpAddressCount"])'
214
250
```

### `setpath(PATHS; VALUE)` 
set `VALUE` for `PATHS`.
```bash
$ cat /tmp/data| jq 'setpath(["Subnets", 0, "AvailableIpAddressCount"]; 0) | .Subnets[].AvailableIpAddressCount'
0
250
```

### `to_entries`, `from_entries`, `with_entries`
`to_entries` converts an array to `{"key": k, "value": v}`.   
`from_entries` converts on the opposite way.    
`with_entries(filter)` is same as `to_entries | map(filter) | from_entries`
```bash
$ cat /tmp/data | jq '.Subnets[].Tags | from_entries'
{
  "Env": "DEV",
  "aws:cloudformation:stack-name": "AccountBase",
  "aws:cloudformation:logical-id": "PrivateSubnet1a",
  "Owner": "Systems",
  "Name": "PrivateSubnet1a"
}
{
  "Owner": "Systems",
  "aws:cloudformation:stack-name": "AccountBase",
  "aws:cloudformation:logical-id": "PublicSubnet1a",
  "Env": "DEV"
}

$ cat /tmp/data | jq '.Subnets[] | to_entries | map(select(.key == "AvailableIpAddressCount"))'
[
  {
    "key": "AvailableIpAddressCount",
    "value": 214
  }
]
[
  {
    "key": "AvailableIpAddressCount",
    "value": 250
  }
]

$ cat /tmp/data | jq '.Subnets[] | with_entries(select(.key == "AvailableIpAddressCount"))'
{
  "AvailableIpAddressCount": 214
}
{
  "AvailableIpAddressCount": 250
}
```

### `select(boolean_expression)` 
produces its input unchanged if it returns true for that input, and produces no output otherwise.

### `arrays`, `objects`, `iterables`, `booleans`, `numbers`, `normals`, `finites`, `strings`, `nulls`, `values`, `scalars` 
selects above objects as result

### `paths` 
outputs the paths to all the elements, which is similar as `path(..)`
`paths(filter)` output the paths which value match `filter`
```bash
$ cat /tmp/data | jq 'paths(select(.Key? == "Env"))'
[
  "Subnets",
  0,
  "Tags",
  0
]
[
  "Subnets",
  1,
  "Tags",
  3
]

$ cat /tmp/data | jq 'getpath(["Subnets", 0, "Tags", 0])'
{
  "Value": "DEV",
  "Key": "Env"
}

$ cat /tmp/data | jq 'getpath(["Subnets", 1, "Tags", 3])'
{
  "Value": "DEV",
  "Key": "Env"
}
```

### `add` 
add all elements of input array 
```bash
$ cat /tmp/data | jq '[.Subnets[].AvailableIpAddressCount] | add'
464

$ cat /tmp/data | jq '[.Subnets[].AvailabilityZone] | add'
"us-east-1aus-east-1a"

$ cat /tmp/data | jq '[.Subnets[] | .AvailabilityZone, .AvailableIpAddressCount | tostring] | add'
"us-east-1a214us-east-1a250"
```

### `any` / `all` / `any(condition)` / `all(condition)`
`any` takes an array of boolean values, and returns `true` if any of them are `true`    
`all` takes an array of boolean values, and returns `true` if all of them are `true`   
`any(condition)` applies `condition` to all elements of given array, and returns `true` if any of them are `true`   
`all(condition)` applies `condition` to all elements of given array, and returns `true` if all of them are `true`    
```bash
$ cat /tmp/data | jq '[.Subnets[0].AvailableIpAddressCount > 220, .Subnets[1].AvailableIpAddressCount > 220] | any '
true

$ cat /tmp/data | jq '[.Subnets[].AvailableIpAddressCount] | any(. > 220)'
true

$ cat /tmp/data | jq '[.Subnets[].AvailableIpAddressCount] | all(. > 220)'
false
```

### `range(upto)` / `range(from; upto)` / `range(from; to; by)`
generates a range of numbers `from` until `upto` with step `by`

### `tonumber` / `tostring`
convert input to number or string

### `type`
returns the type of inputs

### `sort` / `sort_by(path_expression)`
sort an array with following order: 
* `null`
* `false`
* `true`
* nubmers
* strings (alphabetical order)
* array (lexical order)
* object    
or sort the array based on `value` of `path_expression`   
```bash
$ jq -r '[.Subnets[].AvailableIpAddressCount]' /tmp/data
[
  250,
  214
]

$ jq -r '[.Subnets[].AvailableIpAddressCount] | sort' /tmp/data
[
  214,
  250
]
```

### `group_by(path_expression)`
takes as input an array, groups the elements having the same `path_expression` field value into separate arrays, and produces all of these arrays as elements of a larger array.
```bash
$ echo '[{"a": 1}, {"b": 2}, {"a": 1}, {"a": 2}]' | jq 'group_by(.a)'
[
  [
    {
      "b": 2
    }
  ],
  [
    {
      "a": 1
    },
    {
      "a": 1
    }
  ],
  [
    {
      "a": 2
    }
  ]
]
```

### `min` / `max` / `min_by(path_exp)` / `max_by(path_exp)`
get min or max element of input array
```bash
$ cat /tmp/data | jq '[.Subnets[].AvailableIpAddressCount] | min '
214

$ cat /tmp/data | jq '[.Subnets[].AvailableIpAddressCount] | max '
250

$ cat /tmp/data | jq '.Subnets | min_by(.AvailableIpAddressCount)'
{
  "AvailabilityZone": "us-east-1a",
  "Tags": [
    {
      "Value": "DEV",
      "Key": "Env"
    },
    {
      "Value": "AccountBase",
      "Key": "aws:cloudformation:stack-name"
    },
    {
      "Value": "PrivateSubnet1a",
      "Key": "aws:cloudformation:logical-id"
    },
    {
      "Value": "Systems",
      "Key": "Owner"
    },
    {
      "Value": "PrivateSubnet1a",
      "Key": "Name"
    }
  ],
  "AvailableIpAddressCount": 214,
  "DefaultForAz": false,
  "Ipv6CidrBlockAssociationSet": [],
  "State": "available",
  "MapPublicIpOnLaunch": false,
  "SubnetId": "subnet-xxxxxx",
  "CidrBlock": "10.1.2.0/24",
  "AssignIpv6AddressOnCreation": false
}

$ cat /tmp/data | jq '.Subnets | max_by(.AvailableIpAddressCount)'
{
  "AvailabilityZone": "us-east-1a",
  "Tags": [
    {
      "Value": "Systems",
      "Key": "Owner"
    },
    {
      "Value": "AccountBase",
      "Key": "aws:cloudformation:stack-name"
    },
    {
      "Value": "PublicSubnet1a",
      "Key": "aws:cloudformation:logical-id"
    },
    {
      "Value": "DEV",
      "Key": "Env"
    }
  ],
  "AvailableIpAddressCount": 250,
  "DefaultForAz": false,
  "Ipv6CidrBlockAssociationSet": [],
  "State": "available",
  "MapPublicIpOnLaunch": false,
  "SubnetId": "subnet-yyyyyy",
  "CidrBlock": "10.1.0.0/24",
  "AssignIpv6AddressOnCreation": false
}
```

### `unique` / `unique_by(path_exp)`
produces an array without duplicated elements from input array.
```bash
$ cat /tmp/data | jq '[.Subnets[].Tags[]] | unique'
[
  {
    "Value": "DEV",
    "Key": "Env"
  },
  {
    "Value": "PrivateSubnet1a",
    "Key": "Name"
  },
  {
    "Value": "Systems",
    "Key": "Owner"
  },
  {
    "Value": "PrivateSubnet1a",
    "Key": "aws:cloudformation:logical-id"
  },
  {
    "Value": "PublicSubnet1a",
    "Key": "aws:cloudformation:logical-id"
  },
  {
    "Value": "AccountBase",
    "Key": "aws:cloudformation:stack-name"
  }
]

$ cat /tmp/data | jq '[.Subnets[].Tags[]] | unique_by(.Key)'
[
  {
    "Value": "DEV",
    "Key": "Env"
  },
  {
    "Value": "PrivateSubnet1a",
    "Key": "Name"
  },
  {
    "Value": "Systems",
    "Key": "Owner"
  },
  {
    "Value": "PublicSubnet1a",
    "Key": "aws:cloudformation:logical-id"
  },
  {
    "Value": "AccountBase",
    "Key": "aws:cloudformation:stack-name"
  }
]
```

### `reverse`
reverses an input array

### `contains(element)`
evaluate the `element` was included in input
```bash
$ cat /tmp/data | jq '.Subnets[].AvailabilityZone | contains("east")'
true
true

$ cat /tmp/data | jq '.Subnets[].Tags[] | contains({"Key": "Env"})'
false
false
false
true
true
false
false
false
false
```

### `indices(s)`
returns index of `s` or value of key `s`
```bash
$ echo '[{"a": 1}, {"b": 2}, {"a": 1}, {"a": 2}]' | jq '.[] | indices("a")'
1
null
1
2

$ echo '[{"a": 1}, {"b": 2}, {"a": 1}, {"a": 2}]' | jq 'indices({"a": 2})'
[
  3
]
```

### `index(s)` / `rindex(s)`
returns the first index of `s` or last index of `s`
```bash
$ echo '[{"a": 1}, {"b": 2}, {"a": 1}, {"a": 2}]' | jq 'index({"a": 1})'
0

$ echo '[{"a": 1}, {"b": 2}, {"a": 1}, {"a": 2}]' | jq 'rindex({"a": 1})'
2
```

### `inside(s)`
inversed version of `contains`

### `startswith(str)` / `endswith(str)`
```bash
$ cat /tmp/data | jq '[.Subnets[0].Tags[] | {key: .Key, value: .Value}] | from_entries[] '
"Systems"
"AccountBase"
"PublicSubnet1a"
"DEV"

$ cat /tmp/data | jq '[.Subnets[0].Tags[] | {key: .Key, value: .Value}] | from_entries[] | startswith("Sys")'
true
false
false
false

$ cat /tmp/data | jq '[.Subnets[0].Tags[] | {key: .Key, value: .Value}] | from_entries[] | endswith("Base")'
false
true
false
false
```

### `combinations` / `combinations(n)`
outputs all combinations of the elements of input arrays. With `n` means to output `n` repetitions of input array
```bash
$ echo '[[1, 2], [3, 4]]' | jq 'combinations'
[
  1,
  3
]
[
  1,
  4
]
[
  2,
  3
]
[
  2,
  4
]

$ echo '[[1, 2], [3, 4]]' | jq 'combinations(2)'
[
  [
    1,
    2
  ],
  [
    1,
    2
  ]
]
[
  [
    1,
    2
  ],
  [
    3,
    4
  ]
]
[
  [
    3,
    4
  ],
  [
    1,
    2
  ]
]
[
  [
    3,
    4
  ],
  [
    3,
    4
  ]
]
```

### `ltrimstr(str)` / `rtrimstr(str)`
trims input string from left or right

### `explode` / `implode`
convert string to Unicode code point, or convert Unicode code point to string
```bash
$ echo '"matrix"' | jq 'explode'
[
  109,
  97,
  116,
  114,
  105,
  120
]

$ echo "[109, 97, 116, 114, 105,  120]" | jq 'implode'
"matrix"
```

### `split(s)` / `join(s)`
split input based by splitter `s` or join all elements with splitter `s`
```bash
$ echo '["matrix"]' | jq '.'
[
  "matrix"
]

$ echo '["matrix"]' | jq '.[] | split("")'
[
  "m",
  "a",
  "t",
  "r",
  "i",
  "x"
]

$ echo '["matrix"]' | jq '.[] | split("") | join("")'
"matrix"
```

### `ascii_upcase` / `ascii_downcase`
convert input to UpperCase or Lowercase
```bash
$ echo '["matrix"]' | jq '.[] | ascii_upcase'
"MATRIX"
```

### `while(crondition; update)` / `until(crondition; next)`
run `update` while `contidion` is true
run `next` until until `condition` is true
```bash

```

## Examples

### Show all keys 
```
$ cat /tmp/data | jq '. | keys[]'
"Subnets"

$ cat /tmp/data | jq '.Subnets | keys[]'
0
1
```


### Show Specific Element by Index
```
$ cat /tmp/data | jq '.Subnets[0]'
{
  "AvailabilityZone": "us-east-1a",
  "Tags": [
    {
      "Value": "DEV",
      "Key": "Env"
    },
    {
      "Value": "AccountBase",
      "Key": "aws:cloudformation:stack-name"
    },
    {
      "Value": "PrivateSubnet1a",
      "Key": "aws:cloudformation:logical-id"
    },
    {
      "Value": "Systems",
      "Key": "Owner"
    },
    {
      "Value": "PrivateSubnet1a",
      "Key": "Name"
    }
  ],
  "AvailableIpAddressCount": 214,
  "DefaultForAz": false,
  "Ipv6CidrBlockAssociationSet": [],
  "State": "available",
  "MapPublicIpOnLaunch": false,
  "SubnetId": "subnet-xxxxxx",
  "CidrBlock": "10.1.2.0/24",
  "AssignIpv6AddressOnCreation": false
}
```

### Show Multi Attibutes
```
$ cat /tmp/data | jq '.Subnets[].SubnetId, .Subnets[].CidrBlock'
"subnet-xxxxxx"
"subnet-yyyyyy"
"10.1.2.0/24"
"10.1.0.0/24"
```

```
$ cat /tmp/data | jq '.Subnets[] | .SubnetId, .CidrBlock'
"subnet-xxxxxx"
"10.1.2.0/24"
"subnet-yyyyyy"
"10.1.0.0/24"
```

### Filter by value 
```
$ cat /tmp/data | jq '.Subnets[] | .SubnetId, .CidrBlock | select( . == "10.1.0.0/24" )'
"10.1.0.0/24"
```

```
$ cat /tmp/data | jq '.Subnets[] | .SubnetId, .CidrBlock | select( . | test(".*1.0.*") )'
"10.1.0.0/24"
```

```
$ cat /tmp/data | jq '.Subnets[] | {id: .SubnetId, network: .CidrBlock} | select(.network == "10.1.0.0/24")'
{
  "id": "subnet-yyyyyy",
  "network": "10.1.0.0/24"
}
```

### Resharp json
```
$ cat /tmp/data | jq '.Subnets[] | { id: .SubnetId, ip_range: .CidrBlock }'
{
  "id": "subnet-xxxxxx",
  "ip_range": "10.1.2.0/24"
}
{
  "id": "subnet-yyyyyy",
  "ip_range": "10.1.0.0/24"
}
```

### skip null iterator with `?`
```
$ cat /tmp/ss-instances | jq ' .[][].Instances[] | {id: .InstanceId, tags: .Tags[]} | select(.tags.Key | test("^Name$";"i")) | select(.tags.Value | test(".*netapp.*"))'
jq: error (at <stdin>:34578): Cannot iterate over null (null)
```

```
$ cat /tmp/ss-instances | jq ' .[][].Instances[] | {id: .InstanceId, tags: .Tags[]?} | select(.tags.Key | test("^Name$";"i")) | select(.tags.Value | test(".*netapp.*"))'
{
  "id": "i-0908ac3819044a7b4",
  "tags": {
    "Value": "fwawsnetapp01-mediator",
    "Key": "Name"
  }
}
```

### filter case insensitive with `"i"`
```
$ cat /tmp/ss-instances | jq ' .[][].Instances[] | {id: .InstanceId, tags: .Tags[]?} | select(.tags.Key | test("^Name$";"i")) | select(.tags.Value | test(".*netapp.*";"i"))'
{
  "id": "i-0b92c0aa4b6758489",
  "tags": {
    "Value": "System-NetAppCloudManager",
    "Key": "Name"
  }
}
{
  "id": "i-0908ac3819044a7b4",
  "tags": {
    "Value": "fwawsnetapp01-mediator",
    "Key": "Name"
  }
}
```

### filter value based on another is existed
```
$ cat /tmp/data
{
    "Subnets": [
        {
            "AvailabilityZone": "us-east-1a",
            "SubnetId": "subnet-xxxxxx"
        },
        {
            "SubnetId": "subnet-yyyyyy"
        }
    ]
}

$ jq '.Subnets[] | {az: .AvailabilityZone, subnet: .SubnetId} | select(.az != null).subnet ' /tmp/data
"subnet-xxxxxx"
```

### combine 2 values
```bash
$ jq -r '.Subnets[] | (.AvailabilityZone + ", " + .CidrBlock)' /tmp/data
us-east-1a, 10.1.2.0/24
us-east-1a, 10.1.0.0/24
```

### resharp result as an array
```bash
$ jq -r '[.Subnets[] | {info: (.AvailabilityZone + ", " + .CidrBlock)}]' /tmp/data
[
  {
    "info": "us-east-1a, 10.1.2.0/24"
  },
  {
    "info": "us-east-1a, 10.1.0.0/24"
  }
]
```

### `split`
```bash
$ jq -r '.Subnets[] | .AvailabilityZone | split("-")[0]' /tmp/data
us
us
```

### get substring with `capture`
Collects the named captures in a JSON object, with the name of each capture as the key, and the matched string as the corresponding value.
```bash
$ jq -r '.Subnets[].AvailabilityZone | capture("(?<country>[^-]+)")' /tmp/data
{
  "country": "us"
}
{
  "country": "us"
}
```


{% include links.html %}
