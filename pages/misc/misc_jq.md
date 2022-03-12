---
title: jq
tags: [misc]
keywords: json, jq
last_updated: Apr 23, 2021
summary: "parse json with jq"
sidebar: mydoc_sidebar
permalink: misc_jq.html
folder: Misc
---

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

## Examples

### Show all keys 

```
$ cat /tmp/data | jq '. | keys[]'
"Subnets"

$ cat /tmp/data | jq '.Subnets | keys[]'
0
1
```

### Elements count

```
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

### pass parameters from bash
```
$ test_cidr='10.1.0.*'

$ jq -r --arg cidr "${test_cidr}" '.Subnets[] | {cidr: .CidrBlock} | select(.cidr | test($cidr))' /tmp/data
{
  "cidr": "10.1.0.0/24"
}
```

parameter as an integer
```
$ avaiable_ips_threshhold=220                                                                                                                                               

$ jq -r --argjson ip_threshhold "${avaiable_ips_threshhold}" '.Subnets[] | {subnetid: .SubnetId, AvailableIp: .AvailableIpAddressCount} | select(.AvailableIp > $ip_threshhold)' /tmp/data
{
  "subnetid": "subnet-yyyyyy",
  "AvailableIp": 25
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

{% include links.html %}
