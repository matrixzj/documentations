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
### Env Variables
`export TF_LOG=<log_level>`
* INFO
* WARNING
* ERROR
* DEBUG
* TRACE

`export TF_LOG_PATH=<file_name>`

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

#### Provider
```bash
$ cat <<EOF> provider.tf
provider "aws" {
  region = var.region
  s3_use_path_style = true
  skip_credentials_validation = true
  skip_requesting_account_id  = true

  endpoints {
    s3 = "http://aws:4566"
  }
}
EOF
```

### Commands
https://developer.hashicorp.com/terraform/cli/commands/
#### `validate`
Validates the configuration files in a directory

#### `fmt`
Rewrite Terraform configuration files to a canonical format and style

#### `providers`
List all of the provider requirements for all current conguration files
```bash
terraform provides mirror ${target directory}
```
Copy all required provider plugins to a target directory

#### `refresh`
Fetch the current state from all managed remote objects and updates the Terraform state.

#### `graph`
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
### `depends_on`
Explicit Dependency
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

### `lifeCycle` 
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

### `count`
creates that many instances of the resource or module as `count` 
```bash
cat <<EOF >random.tf
resource "random_string" "string" {
  length = 6
  count = 3
}
EOF

cat <<EOF >variable.tf
variable "project-users" {
     type = list(string)
     default = [ "matrix1", "matrix2"]
}
EOF

cat <<EOF >pet.tf
resource "random_pet" "pets" {
     prefix = var.project-users[count.index]
     count = length(var.project-users)
     length = 2
}
EOF
```

### `for-each`
need to defined as `set` or `map`
```bash
$ cat <<EOF > variable.tf
variable "filename" {
    default = [
        "matrix1.txt",
        "matrix2.txt"
    ]
}
EOF

$ cat <<EOF > local.tf
resource "local_file" "matrix" {
    filename = each.value
    for_each = toset(var.filename)
    content = "${each.value}"
}
EOF
```

## Datasources
```bash
data "local_file" "terraform" {
  filename = "time.tf"
}
```

## Version Constraints
```bash
terraform {
    required_providers {
        local = {
            source = "hashicorp/local"
            version = "1.4.0"
        }
    }
}
```
`=` or no operator: eqaul

`!=`: not equal

`>`, `>=`, `<`, `<=`: Comparisons against a specified version, allowing versions for which the comparison is true. "Greater-than" requests newer versions, and "less-than" requests older versions.

`~>`: Allows only the rightmost version component to increment. For example, to allow new patch releases within a specific minor release, use the full version number: ~> 1.0.4 will allow installation of 1.0.5 and 1.0.10 but not 1.1.0. This is usually called the pessimistic constraint operator.

## State File
### Remote State 
#### OBS
```bash
cat <<EOF> terraform.tf
terraform {
  backend "s3" {
    bucket = "matrix-obs-1"
    key    = "terraform/terraform.tfstate"
    endpoint = "https://obs.ae-ad-1.vb.g42cloud.com"
    region = "ae-ad-1"
    access_key = "{access key}"
    secret_key = "{secret key}"
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}
EOF

terraform init
```

### `state` cmd
`terraform state list` list all resources  
`terraform state show <address>` show the attributes of a single resource   
`terraform state mv SOURCE DESTINATION` move resource in state file   
`terraform state rm ADDRESS` remove resource in state file

## Provisioners
```bash
cat terraform.tf
......
    provisioner "remote-exec" {
        echo "this is a remote provisioner from terraform" >> /tmp/terraform.txt
    }
    connection {
        type = "ssh"
        host = self.public_ip
        user = "ubuntu"
        private_key = file(~/.ssh/id_rsa)
    }
.....
```

## Module
Make code more easier to be reused. 
More modules can be checked from [Terraform Offical Registry](https://registry.terraform.io/modules)
```bash
$ tree .
.
├── dido
│   ├── main.tf
├── local_file
│   ├── main.tf
│   └── variable.tf
└── matrix
    └── main.tf

3 directories, 4 files

$ cat local_file/main.tf
resource "local_file" "localfile" {
    filename = "/tmp/${var.name}/module.txt"
    content = "it was generated by module with var: ${var.name}"
}

$ cat local_file/variable.tf
variable "name" {
    type = string
}

$ cat matrix/main.tf
module "local_file_matrix" {
    source = "../local_file"
    name = "matrix"
}

$ cat dido/main.tf
module "local_file_dido" {
    source = "../local_file"
    name = "dido"
}
```


{% include links.html %}