# RDS Module

You can use this module to create RDS cluster with existing db subnet group/parameter groups.


## Argument reference

Input

| Field      | Description | Required|
| ----------- | ----------- |---------|
| db_name | a uniq name or purpose for this rds | yes|
| engine_version | default "12.8" | no |
|master_password | default: random password if variable all_stage_password not defined | no |
| deletion_protection | default : yes| no|
| vpc_id | vpc id | yes |
| db_subnet_group_name | name of the db subnet group |  yes| 
| db_cluster_parameter_group_name | name of the db cluster parameter group | yes |
| db_parameter_group_name  | name of the db parameter group | yes |
| publicly_accessible | is it accessible by public - default False  | no | 
| instance_class | default : db.r6g.large | no |
| create_monitoring_role | default : true - tips creating role will not be allowed by IS in the future | no|
| monitoring_role_arn | arn of the enhanced monitoring role -  we will ask IS to create the role first | no |
| monitoring_interval|default : 0|no|
| enabled_cloudwatch_logs_exports| Set of log types to export to cloudwatch. default postgresql. The following log types are supported: `audit`, `error`, `general`, `slowquery`, `postgresql`"| no|
| default_tags  |default cost center tags | yes|
| tags | dba customised tags | no |

Output values:

| value      | Description | 
| ----------- | ----------- |
|cluster_main_endpoint_map| a list of map which contains rds.cluster_database_name => rds.cluster_endpoint |
|cluster_reader_endpoint| a list of map which contains rds.cluster_database_name => rds.cluster_reader_endpoint |
|rds_db_security_group_id| a list of map which contains rds.cluster_database_name => rds.security_group_id|

## Folder layout
```
deploy/<your-environment>
├── rds
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
  source = "git::https://gitlab.enterprise.com/common/terraform-modules.git//aws/rds"
  ### ou can stick to a specific version so any further module update won't impact your exisitng infra
  # source = "git::https://gitlab.enterprise.com/common/terraform-modules.git//aws/rds?ref=v0.2"
}

include root {
  path = find_in_parent_folders()
  expose = true
}

dependency "midware-env" {
  config_path  = "../midware-env"
  mock_outputs = {
    aws_rds_cluster_parameter_group-pg12-paragroup = "temporary-aws_rds_cluster_parameter_group-pg12-paragroup",
    aws_db_parameter_group-pg12-paragroup = "temporary-aws_db_parameter_group-pg12-paragroup",
    aws_rds_cluster_parameter_group-mysql-paragroup = "temporary-aws_rds_cluster_parameter_group-mysql-paragroup",
    aws_docdb_cluster_parameter_group-docdb-paragroup = "temporary-aws_docdb_cluster_parameter_group-docdb-paragroup",
    aws_db_subnet_group = "temporary-aws_db_subnet_group"
    aws_elasticache_subnet_group = "temporary-aws_elasticache_subnet_group"
  }
}

###  use the default_tags defined in the provider.tf
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

 rds_clusters = {
    aip = {
      db_name = "aip"
      engine_version = "12.8"
      db_subnet_group_name            = dependency.midware-env.outputs.aws_db_subnet_group
      db_cluster_parameter_group_name = dependency.midware-env.outputs.aws_rds_cluster_parameter_group-pg12-paragroup
      db_parameter_group_name         = dependency.midware-env.outputs.aws_db_parameter_group-pg12-paragroup
      publicly_accessible = false
      instance_class = "db.r6g.large"
      create_monitoring_role = false
      ## monitoring_role_arn = <this will be created by IS IAM manager>
      enabled_cloudwatch_logs_exports = ["postgresql"]
      default_tags             = dependency.default-tags.outputs.tags

      tags = {
        "environment"    = try(include.root.inputs.env, null)
        "region"         = try(include.root.inputs.region, null)
        "product_line"   = try(include.root.inputs.product_line, null)
        "db_app"         = "bus2" 
        "db_apptype"     = "oltp"
        "db_class"       = "db.r6g.large"
        "db_comments"    = ""
        "db_dba"         = "dba1 
        "db_devowner"    = "dba1"
        "db_env"         = "stage" 
        "db_level"       = "2" 
        "db_module"      = "aip" 
        "db_provider"    = "awscloudb"
        "db_region"      = "ap-southeast-1" 
        "db_usagestatus" = "using" 
      }
    }
  }


}


```



