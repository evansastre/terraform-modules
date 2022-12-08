# Midware envrionment Module

You can use this module to create the db_subnet_group and parameter groups shared by the same product line.

| resources to be created |
| ------------|
|aws_db_parameter_group : pg12-paragroup|
|aws_rds_cluster_parameter_group : pg12-paragroup|
|aws_rds_cluster_parameter_group : mysql-paragroup|
|aws_docdb_cluster_parameter_group : docdb-paragroup|
|aws_msk_configuration : for kafka|
|aws_db_subnet_group : for rds|
|aws_elasticache_subnet_group : for redis|

## Argument reference

Input

| Field      | Description | Required|
| ----------- | ----------- |---------|
| env | environment |  yes |
| region |region: jp, sg etc. | yes|
| product_line  |  you can put project-subproject here | yes|
| subnet_ids| use this to create the db subnet group| yes|

Output values:

| value      | Description | 
| ----------- | ----------- |
|aws_rds_cluster_parameter_group-pg12-paragroup| name of this pg12 rds cluster parameter group|
|aws_db_parameter_group-pg12-paragroup| name of the pg12 db parameter group|
|aws_rds_cluster_parameter_group-mysql-paragroup| name of the mysql parameter group|
|aws_docdb_cluster_parameter_group-docdb-paragroup| name of the docdb cluster parameter group|
|aws_msk_configuration_arn| ARN of this msk config|
|aws_db_subnet_group| name of the rds db subnet group|
|aws_elasticache_subnet_group| name of the elasticcache(redis) subnet group|

## Folder layout
```
deploy/<your-environment>
├── midware-env
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

this is an example for midware-env/terragrunt.hcl
```
terraform {
  source = "git::https://gitlab.enterprise.com/common/terraform-modules.git//aws/midware-env"
  ### ou can stick to a specific version so any further module update won't impact your exisitng infra
  # source = "git::https://gitlab.enterprise.com/common/terraform-modules.git//aws/midware-env?ref=v0.2"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  subnet_ids = [
    "subnet-00861f8aee4829082",
    "subnet-077d6debdd43749a0",
    "subnet-01be31d2457a87e50"
  ]
}
 

```



