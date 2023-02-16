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
    - [sort keys `-S`](#sort-keys--s)
    - [compact output `-c`](#compact-output--c)
    - [read filter from file `-f`](#read-filter-from-file--f)
    - [pass parameters from bash `--arg` / `--argjson`](#pass-parameters-from-bash---arg----argjson)
    - [reads JSON from `file` and binds to a JSON array named as given global variable `--slrupfile`](#reads-json-from-file-and-binds-to-a-json-array-named-as-given-global-variable---slrupfile)
  - [Types and Values](#types-and-values)
    - [`..` Recursive Descent](#-recursive-descent)
  - [Built-in Functions](#built-in-functions)
    - [`length` gets the length of various different types of value](#length-gets-the-length-of-various-different-types-of-value)
    - [`keys` / `keys_unsorted` returns its keys in an array](#keys--keys_unsorted-returns-its-keys-in-an-array)
    - [`has(key)` returns whether the input object has the given key / `in` returns the input key is in the given object, or the input index corresponds to an element in the given array](#haskey-returns-whether-the-input-object-has-the-given-key--in-returns-the-input-key-is-in-the-given-object-or-the-input-index-corresponds-to-an-element-in-the-given-array)
    - [`map(x)` / `map_values(x)` apply filter `x` to each element of the input array](#mapx--map_valuesx-apply-filter-x-to-each-element-of-the-input-array)
    - [`path(path_expression)` returns array representations of the given path expression in `.`. The outputs are arrays of strings (object keys) and/or numbers (array indices).](#pathpath_expression-returns-array-representations-of-the-given-path-expression-in--the-outputs-are-arrays-of-strings-object-keys-andor-numbers-array-indices)
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
### sort keys `-S`
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

### compact output `-c`
```bash
$ cat /tmp/jq-data | jq -c
{"Subnets":[{"AvailabilityZone":"us-east-1a","Tags":[{"Value":"DEV","Key":"Env"},{"Value":"AccountBase","Key":"aws:cloudformation:stack-name"},{"Value":"PrivateSubnet1a","Key":"aws:cloudformation:logical-id"},{"Value":"Systems","Key":"Owner"},{"Value":"PrivateSubnet1a","Key":"Name"}],"AvailableIpAddressCount":214,"DefaultForAz":false,"Ipv6CidrBlockAssociationSet":[],"State":"available","MapPublicIpOnLaunch":false,"SubnetId":"subnet-xxxxxx","CidrBlock":"10.1.2.0/24","AssignIpv6AddressOnCreation":false},{"AvailabilityZone":"us-east-1a","Tags":[{"Value":"Systems","Key":"Owner"},{"Value":"AccountBase","Key":"aws:cloudformation:stack-name"},{"Value":"PublicSubnet1a","Key":"aws:cloudformation:logical-id"},{"Value":"DEV","Key":"Env"}],"AvailableIpAddressCount":250,"DefaultForAz":false,"Ipv6CidrBlockAssociationSet":[],"State":"available","MapPublicIpOnLaunch":false,"SubnetId":"subnet-yyyyyy","CidrBlock":"10.1.0.0/24","AssignIpv6AddressOnCreation":false}]}
```

### read filter from file `-f`
```bash
$ cat /tmp/filter
.Subnets[].AvailabilityZone

$ cat /tmp/jq-data | jq -r -f /tmp/filter
us-east-1a
us-east-1a
```

### pass parameters from bash `--arg` / `--argjson`
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

### reads JSON from `file` and binds to a JSON array named as given global variable `--slrupfile`
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
### `length` gets the length of various different types of value
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

### `keys` / `keys_unsorted` returns its keys in an array
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

### `has(key)` returns whether the input object has the given key / `in` returns the input key is in the given object, or the input index corresponds to an element in the given array
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

### `map(x)` / `map_values(x)` apply filter `x` to each element of the input array
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

### `path(path_expression)` returns array representations of the given path expression in `.`. The outputs are arrays of strings (object keys) and/or numbers (array indices).
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
