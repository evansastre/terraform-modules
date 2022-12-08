# Security group Module

You can use this module to create one or more secuirty group with a default outbound rule(allow all traffic out). 


## Argument reference

Input

| Field      | Description | Required|
| ----------- | ----------- |---------|
| name | security group name  |  yes |
| description |description| yes|
| vpc_id  |  vpc id | yes|
| default_tags | default tags must be provided | yes|

Output values:

| value      | Description | 
| ----------- | ----------- |
|  id | a map of sg name -> sg id|

## Folder layout
```
deploy/<your-environment>
├── security-group
│   └── terragrunt.hcl
|── <other components>
|   └── ...
├── terragrunt.hcl         ### this is the parent terragrunt.hcl


```
The root terragrunt.hcl will create/override versions_override.tf, backend.tf and provider.tf

```
remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    bucket         = "<your s3 bucker for tf state file>"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "ap-southeast-1"
    encrypt        = true
  }
}

generate "versions" {
  path      = "versions_override.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
    terraform {
      required_providers {
        aws = {
          source = "hashicorp/aws"
          version = ">=4.5.0"
        }
        null = {
          source = "hashicorp/null"
          version = "3.1.0"
        }
        random = {
          source = "hashicorp/random"
          version = "3.1.0"
        }
      }
    }
EOF
}

generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
provider "aws" {
  default_tags {
    tags = {
      school = "bus2"
      project = "bus2"
      subproject = "null"
      envir = "demo"
      owner = "owner"
      }

    }
 }
EOF
}

##### these are the variabels to be shared cross all sub-modules like ec2/rds/eks/efs/msk and .etc.
inputs = {
  region = "sg"
  env = "pft"
  product_line = "bus2"

  ## vpc
  vpc_id = "vpc-0fbedde4950923c9b"
}
```

this is an example for security-group/terragrunt.hcl
```
terraform {
  source = "git::https://gitlab.enterprise.com/common/terraform-modules.git//aws/security-group"
  ### ou can stick to a specific version so any further module update won't impact your exisitng infra
  # source = "git::https://gitlab.enterprise.com/common/terraform-modules.git//aws/security-group?ref=v0.2"
}

include root {
  path = find_in_parent_folders()
  expose = true
}

###  retrive the default_tags defined in the provider.tf - parent terragrunt.hcl
dependency "default-tags"{
    config_path  = "../default-tags"
    mock_outputs = {
      tags = {
        school = "bus2"
        project = "bus2"
        subproject = "null"
        envir = "demo"
        contact = "contact"
      }
    }
}

inputs = {

    security_groups = {
      "security-name-xxxx-1" = {
        name = "security-name-xxxx-1"
        description= "test 1"
        vpc_id = "vpc-0308080ea4774ad33"  ## or include.root.inputs.vpc_id
        ## must use default_tags here for cost center purpose
        tags = merge(dependency.default-tags.outputs.tags,
        ### define your own key-value tag here
                     {mykey = "myvalue"}
              )
      }
      "security-name-xxxx-2" = {
        name = "security-name-xxxx-2"
        description= "test 2"
        vpc_id = "vpc-0308080ea4774ad33"
        tags = merge(dependency.default-tags.outputs.tags,
                     {mykey = "myvalue"}
        )
     }
  
    }
}
```



