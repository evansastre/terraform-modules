# ECR Module

This module is to create a MSK with default settings.


## Argument reference

Input

| Field      | Description | Required|
| ----------- | ----------- |---------|
| vpc_id    |  VPC ID for the MSK cluster - we need to get this from security team     | Yes|
| default_tags | aws_default_tags defined in the provider.tf| yes|
| name | purpose of this MSK cluster, it will be part of the cluster name: "${var.env}-${var.region}-${var.product_line}-${var.name}-msk"       | Yes|
|client_subnets|a list of subnet_ids which is used by kafka brokers.| Yes|
|kms_key_admin| a list of user arn who is the key admin|Yes|
|kms_key_user|a list of user arn who is the key user|Yes|
|kms_key_attachment|a list of user arn who has the permission of Allow attachment of persistent resources.|Yes|
|create_msk_configuration| whether to create a new msk config or not: default True| No|
|existing_msk_configuration_name| if choose to reuse an existing msk config(create_msk_configuration = False), then pleaes provide the name of the config: default null|No|
|auto_create_topics|whether to create kafka topics automatically: default False|NO|
|env|environment variable is also a part of the MKS cluster name. default: dev |No|
|region|region is also a part of the MKS cluster name. default: tky|No|
|product_line| which product line this msk cluster belongs to. it’s a part of the MKS cluster name. default: bus2|No|
|key_usage|KMS key usage. default: ENCRYPT_DECRYPT|No|
|region|KMS key spec. default: SYMMETRIC_DEFAULT|No|
|customer_master_key_spec|region is also a part of the MKS cluster name.|No|
|retention_in_days|days of retention for cloudwatch log group. default: 30|No|
|msk_instance_type|Kafka node instance type. default: kafka.t3.small|No|
|all_stage_password|rpassword for non prod MSK cluster. default: ““.|No|
|ebs_volume_size|disk size attached to the instance. default: 1GB|No|
|kafka_version| kafka version. default: “2.6.2”|No|
|number_of_broker_nodes|number of broker nodes. default: 3|No|
|msk_config_revision|revision number of the msk config. default: 1|No|
|tags|tags: default {}|No|
|principal_type| the IdP of the principal which is used in the KMS key policy. default: “AWS“. allowed values[“AWS“, “FEDERATED“]|No|

Output values:

| value      | Description | 
| ----------- | ----------- |
| msk_security_group_id | Security Group ID for this MSK Cluster.|

## Folder layout
```
deploy/pft
├── msk
│   └── terragrunt.hcl
|── <other components>
|   └── ...
├── terragrunt.hcl
├── backend.tf
├── povider.tf
└── versions_override.tf

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
  vpc_id = "vpc-0fbedde4950923c9b"
}
```

this is an example for msk/terragrunt.hcl
```
terraform {
  source = "git::https://gitlab.enterprise.com/devops/terraform-modules.git//aws/msk"
  ### you can stick to a specific version so any further module update won't impact your exisitng infra
}
include root {
  path = find_in_parent_folders()
  expose =true
}
iinputs = {
  name                  = "<purpose of this cluster>"

  ## get the subnets id from security team
  client_subnets  = [
    "subnet-0eba0c22e068a4435",
    "subnet-0ff3df0a5bfd26b57",
    "subnet-0e154dd604717feef"
  ]


### option 1: creeate a new MSK configuration
  create_msk_configuration = true

### option 2: reuse existing msk config #####
## create_msk_configuration = false
## existing_msk_configuration_name = "demo-sg-bus2-msk"


## msk config: create the kafka topic automatically
  auto_create_topics = true


  msk_instance_type   = "kafka.m5.large"
  ebs_volume_size     = 100
  
}
```



