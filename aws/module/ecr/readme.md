# ECR Module

This module is to create a AWS container registry with default settings.


## Argument reference

Input

| Field      | Description | Required|
| ----------- | ----------- |---------|
| name    |  the name of the ECR.       | Yes|
| principals_read_write_access | a list of ARN which has the ECR read-write access ： please make sure you've create the default role eksNodeInstanceRole in this aws account already  | No|
|image_tag_mutability(optional)|enable image tag immutability or not. default: "MUTABLE"| No|
|encryption_type(optional)|Encryption type for the repository - AES256 or KMS. default: "AES256"|No|
|kms_key(optional)|This field must work with encryptopn type - KMS|No|
|enable_scan_on_push|scanning configuration for image scanning - default False|No|
|max_image_count|max number of the image -default 500|No|
|tags| must provide cost center tags: school, project, subproject, envir, contact| Yes|

Output values:

| value      | Description | 
| ----------- | ----------- |
|arn| the arn of this ECR.|
|registry_id| registry ID.|

## Folder layout
```
deploy/pft
├── ecr
│   └── terragrunt.hcl
|── <other components>
|   └── ...
├── terragrunt.hcl

```
The root terragrunt.hcl will create/override versions_override.tf, backend.tf and provider.tf

How to run the script manually
```
cd /deploye/pft  ### WHERE you can find the root terragrunt.hcl
terragrunt run-all plan
terragrunt run-all apply
```


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
  region = "ap-southeast-1"
  default_tags {
    tags = {
      school = "bus2"
      project = "bus2"
      subproject = ""
      envir = "demo"
      owner = "owner"
      }

    }
 }
EOF
}
##### these are the variabels to be shared cross all modules like rds/eks/efs/msk and .etc.
inputs = {
  region = "sg"
  env = "pft"
  product_line = "bus2"

  all_stage_password = "this-is-just-a-demo"
  ## vpc
  vpc_id = "vpc-xxxxxxxxxxx"
}
```

this is an example for ecr/terragrunt.hcl
```
terraform {
  source = "git::https://gitlab.enterprise.com/devops/terraform-modules.git//aws/ecr"
}
include root {
  path = find_in_parent_folders()
  expose =true
}
inputs = {
  ## ECR name
  name                  = "beta"
  
  ### required for cost center tags
  tags = merge(dependency.default-tags.outputs.tags,
    {}
  )
}
```



