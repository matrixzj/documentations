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
                    "Value": "Ops-Sandbox",
                    "Key": "Project"
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
                },
                {
                    "Value": "arn:aws:cloudformation:us-east-1:392697640131:stack/AccountBase/f8d43350-f272-11e8-b9be-50fae9826c99",
                    "Key": "aws:cloudformation:stack-id"
                }
            ],
            "AvailableIpAddressCount": 214,
            "DefaultForAz": false,
            "Ipv6CidrBlockAssociationSet": [],
            "VpcId": "vpc-0f54cb3791fe5ccbb",
            "State": "available",
            "MapPublicIpOnLaunch": false,
            "SubnetId": "subnet-011027c9a5b395c2c",
            "CidrBlock": "10.35.2.0/24",
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
                    "Value": "arn:aws:cloudformation:us-east-1:392697640131:stack/AccountBase/f8d43350-f272-11e8-b9be-50fae9826c99",
                    "Key": "aws:cloudformation:stack-id"
                },
                {
                    "Value": "AccountBase",
                    "Key": "aws:cloudformation:stack-name"
                },
                {
                    "Value": "PublicSubnet1a",
                    "Key": "Name"
                },
                {
                    "Value": "Ops-Sandbox",
                    "Key": "Project"
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
            "VpcId": "vpc-0f54cb3791fe5ccbb",
            "State": "available",
            "MapPublicIpOnLaunch": false,
            "SubnetId": "subnet-00498dd23f3bd3e98",
            "CidrBlock": "10.35.0.0/24",
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
      "Value": "Ops-Sandbox",
      "Key": "Project"
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
    },
    {
      "Value": "arn:aws:cloudformation:us-east-1:392697640131:stack/AccountBase/f8d43350-f272-11e8-b9be-50fae9826c99",
      "Key": "aws:cloudformation:stack-id"
    }
  ],
  "AvailableIpAddressCount": 214,
  "DefaultForAz": false,
  "Ipv6CidrBlockAssociationSet": [],
  "VpcId": "vpc-0f54cb3791fe5ccbb",
  "State": "available",
  "MapPublicIpOnLaunch": false,
  "SubnetId": "subnet-011027c9a5b395c2c",
  "CidrBlock": "10.35.2.0/24",
  "AssignIpv6AddressOnCreation": false
}
```

#### Show Multi Attibutes

```
$ cat /tmp/data | jq '.Subnets[].SubnetId, .Subnets[].CidrBlock'
"subnet-011027c9a5b395c2c"
"subnet-00498dd23f3bd3e98"
"10.35.2.0/24"
"10.35.0.0/24"
```

```
$ cat /tmp/data | jq '.Subnets[] | .SubnetId, .CidrBlock'
"subnet-011027c9a5b395c2c"
"10.35.2.0/24"
"subnet-00498dd23f3bd3e98"
"10.35.0.0/24"
```

#### Filter by value 

```
$ cat /tmp/data | jq '.Subnets[] | .SubnetId, .CidrBlock | select( . == "10.35.0.0/24" )'
"10.35.0.0/24"
```

```
$ cat /tmp/data | jq '.Subnets[] | .SubnetId, .CidrBlock | select( . | test(".*35.2.*") )'
"10.35.2.0/24"
```

```
$ cat /tmp/data | jq '.Subnets[] | {id: .SubnetId, network: .CidrBlock} | select(.network == "10.35.0.0/24")'
{
  "id": "subnet-00498dd23f3bd3e98",
  "network": "10.35.0.0/24"
}
```

{% include links.html %}
