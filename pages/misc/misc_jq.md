---
title: jq
tags: [misc]
keywords: json, jq
last_updated: Sep 4, 2019
summary: "parse json with jq"
sidebar: mydoc_sidebar
permalink: misc_jq.html
folder: Misc
---

## jq
=====

### data

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

### Examples

#### Elements count

```
$ cat /tmp/data | jq '.Subnets | length'
2
```

#### Show Specific Element by Index

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

#### Show Multi Attibutes

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

#### Filter by value 

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

#### Resharp json

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

{% include links.html %}
