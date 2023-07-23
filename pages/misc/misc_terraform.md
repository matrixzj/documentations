---
title: Terraform
tags: [misc]
keywords: Terraform, Learning
last_updated: Jul 21, 2023
summary: "Terraform Learning"
sidebar: mydoc_sidebar
permalink: terraform.html
folder: Misc
---

# Terraform
======

## Installation
[Official Download Link](https://developer.hashicorp.com/terraform/downloads)
```bash
$ curl -s -o /tmp/terraform_1.5.3_linux_amd64.zip 'https://releases.hashicorp.com/terraform/1.5.3/terraform_1.5.3_linux_amd64.zip'
$ unzip /tmp/terraform_1.5.3_linux_amd64.zip -d /tmp/
$ chmod 755 /tmp/terraform
$ sudo mv /tmp/terraform /usr/local/bin/
```
Verify
```bash
$ terraform version
Terraform v1.5.3
on linux_amd64
```

## HCL (HashiCorp Configuration Language) Syntax
```bash
<block> <parameters> {
    key1 = value1
    key2 = value2
}
```
Example
```bash
resource "local_file" "pet" {
    filename = "/root/pets.txt"
    contennt = "We love pets"
}
```
block name:         `resource`
resource type:      `local_file`, `local` is provider and `file` is `resource`
resource name:      `pet`

## Terraform General Workflow
* Compile Terraform Files
* `terraform init`, understand providers will be used, download it
* `terraform plan`, check execution plan which is what will be done by Terraform
* `terraform apply`, implemnt execution plan

## Basics
### Variables
Type (Optional)
| Key | Example | Note |
| :------ | :------ | :------ |
| string | "pets.txt" | |
| number | 1 | |
| bool | true/false | |
| any | Default Value | |
| list | ["cat", "dog", "cat"] | |
| set | ["cat", "dog"] | can't have duplicate element |
| map | pet1 = cat <br/> pet2 = dog | |
| object | Complex Data Structure | |
| tuples | Complex Data Structue | can have different type of elements, but `list` can't |

```bash
$ cat <<EOF >variables.tf
variable "filename" {
    default = "pets.txt"
    type = string
}

variable "content" {
    default = "We love panda"
    type = string
}

variable "prefix" {
    default = "Mrs"
    type = string
}

variable "separator" {
    default = "."
    type = string
}

variable "length" {
    default = 3
    type = number
}
EOF

$ cat <<EOF >file.tf
resource "local_file" "pet" {
    filename = var.filename
    content  = var.content
    file_permission = "0700"
}

resource "random_pet" "my-pet" {
    prefix = var.prefix
    separator = var.separator
    length = var.length
}
EOF
```

Variable files will be automatically loaded: 
* terraform.tfvars (`variable.tf` is needed)
* terraform.tfvars.json (`variable.tf` is needed)
* *.auto.tfvars (`variable.tf` is needed)
* *.auto.tfvars.json (`variable.tf` is needed)
* *.tf

Variable Definition Percedence
| Order | Operation |
| :------ | :------  |
| 1 | Environment Variables |
| 2 | terraform.tfvars | 
| 3 | *.auto.tfvars(alphabetical order) | 
| 4 | `-var` or `-var-file` cmd parameters |

### Resources 
#### Resource Attribute
```bash
$ cat <<EOF > file.tf
resource "local_file" "pet" {
    filename = var.filename
    content  = "current time is ${time_static.time_current.id}"
    file_permission = "0700"
}

resource "time_static" "time_current" {
}
EOF
```

#### Output Variable
```bash
$ cat <<EOF> time.tf
resource "time_static" "time_current" {
}

output "time" {
    value = time_static.time_current.id
}
EOF

$ terraform output
time = "2023-07-22T13:20:26Z"
```

### Commands
https://developer.hashicorp.com/terraform/cli/commands/
#### `validate`
Validates the configuration files in a directory

### `fmt`
Rewrite Terraform configuration files to a canonical format and style

### `providers`
List all of the provider requirements for all current conguration files
```bash
terraform provides mirror ${target directory}
```
Copy all required provider plugins to a target directory

### `refresh`
Fetch the current state from all managed remote objects and updates the Terraform state.

### `graph`
Outputs the visual execution graph.
```bash
terraform graph | dot -Tsvg > graph.svg
```
![terraform-graph](images/misc/terraform-graph.jpg.jpg)

## State
Json formatted, non-operational 
`terraform show` to inspect latest state snapshot. 
`terraform output` to show all output values or specific named values from latest state snapshot.

## Meta-Arguments
### Dependency (Explicit Dependency)
```bash
cat <<EOF> file.tf
resource "local_file" "pet" {
    filename = var.filename
    content  = "current time is"
    file_permission = "0700"
    depends_on = [
        time_static.time_current
    ]
}

resource "time_static" "time_current" {
}
EOF
```

### LifeCycle 
#### Create new resources before destroy old resources
```bash
  lifecycle {
    create_before_destroy = true
  }
```

#### Prevent resources to be deleted during changes
```bash
  lifecycle {
    prevent_destroy = true
  }
```

#### Ignore changes to Resources Attributes (specific / all)
```bash
  lifecycle {
    ignore_changes = [
      ${attribute list}
    ]
  }
```

## Datasources
```bash
data "local_file" "terraform" {
  filename = "time.tf"
}
```

{% include links.html %}