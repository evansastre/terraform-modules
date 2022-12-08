# Security group Module

You can use this module to create one or more secuirty group rules and associate then with existing security groups. 


## Argument reference

Input

| Field      | Description | Required|
| ----------- | ----------- |---------|
| security_group_id | Security group to apply this rule to. | yes|
| type      |  Type of rule being created. Valid options are ingress (inbound) or egress (outbound).| yes|
| from_port|  Start port (or ICMP type number if protocol is "icmp" or "icmpv6").| yes| 
| to_port  | End port (or ICMP code if protocol is "icmp").| yes |
| protocol | Protocol. If not icmp, icmpv6, tcp, udp, or all use the protocol number| yes|
| description | description of this rule| no|
| self |  (ingress only) Whether the security group itself will be added as a source to this ingress rule. Cannot be specified with cidr_blocks, ipv6_cidr_blocks, or source_security_group_id. | no |
| cidr_blocks  |  List of CIDR blocks. Cannot be specified with source_security_group_id or self. | no|
| source_security_group_id | ecurity group id to allow access to/from, depending on the type. Cannot be specified with cidr_blocks, ipv6_cidr_blocks, or self.| no|
  prefix_list_ids |  List of Prefix List IDs. | no |

Output values:

| value      | Description | 
| ----------- | ----------- |
|  none| none| no|

## Folder layout
```
deploy/<your-environment>
├── sg-rules
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
  vpc_id = "vpc-xxxxxxxxxxxxx"
}
```

this is an example for sg-rule/terragrunt.hcl
```
terraform {
  source = "git::https://gitlab.enterprise.com/common/terraform-modules.git//aws/sg-rules"
  ### ou can stick to a specific version so any further module update won't impact your exisitng infra
  # source = "git::https://gitlab.enterprise.com/common/terraform-modules.git//aws/sg-rules?ref=v0.2"

}

include {
  path = find_in_parent_folders()
}

dependency "security-group"{
    config_path  = "../security-group"
    mock_outputs = {
       id = { "security-name-xxxx-1" = "test-111111" }
    }
}

inputs = {
    ### example: allow traffic within the same security group: self
    sg_rules = {
      sg_rule_1 = {
        security_group_id = "sg-xxxxxxxxxxxxxx"
        description =  "test"
        type = "ingress"
        from_port = 53
        to_port = 53
        protocol = "tcp"
        self = true
      }
    ###e xample:  allow traffic from a sepecific cidr :  "10.0.0.0/16"
       sg_rule_2 = {
        security_group_id = dependency.security-group.outputs.id["security-name-xxxx-1"]
        type = "egress"
        from_port = 53
        to_port = 53
        protocol = "tcp"
        cidr_blocks = "10.0.0.0/16"
      }
     ### example:  allow traffic from another security group :  sg-id
       sg_rule_3 = {
        security_group_id = "sg-xxxxxxxxxxxxxxxxx"
        type = "ingress"
        from_port = 53
        to_port = 53
        protocol = "tcp"
        source_security_group_id = "sg-xxxxxxxxxxxx"
      }
    ### example: allow traffic to a prefix id: like s3 vpc endpoint
       sg_rule_4 = {
        security_group_id = "sg-xxxxxxxxxxxxxxxxx"
        type = "egress"
        from_port = 53
        to_port = 53
        protocol = "tcp"
        prefix_list_ids = "pl-6fa54006"
      }
    }
  

}
```



