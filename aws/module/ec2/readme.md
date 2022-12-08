# EC2 Module

This module could create one or multiple EC2 instances. It's modified based on the terraform-aws-modules/ec2-instance/aws because we need to ensure all cost center tags are in place.


## Argument reference

Input

| Field      | Description | Required|
| ----------- | ----------- |---------|
| name | instance name  |  yes |
| default_tags | aws_default_tags defined in the provider.tf| yes|
| ami  | ami id      |   yes |
| instance_type  |    The type of instance to start |   no|
| vpc_security_group_ids |A list of security group IDs to associate with | no|
| subnet_id    |The VPC Subnet ID to launch in | no|
| key_name   | Key name of the Key Pair to use for the instance; which can be managed using the aws_key_pair resource | no| 
| monitoring  | If true, the launched EC2 instance will have detailed monitoring enabled | no|
| availability_zone  | AZ to start the instance in | no |
| placement_group  | The Placement Group to start the instance in | no |
| associate_public_ip_address | Whether to associate a public IP address with an instance in a VPC	 | no| 
| disable_api_stop  | If true, enables EC2 Instance Stop Protection. | no |
| hibernation | If true, the launched EC2 instance will support hibernation | no|
| enclave_options_enabled |Whether Nitro Enclaves will be enabled on the instance. Defaults to false| no |
| user_data_base64  |Can be used instead of user_data to pass base64-encoded binary data directly. | no |
| user_data_replace_on_change | When used in combination with user_data or user_data_base64 will trigger a destroy and recreate when set to true. Defaults to false if not set.| no |
| cpu_core_count| Sets the number of CPU cores for an instance.	| no|
| cpu_threads_per_core  | Sets the number of CPU threads per core for an instance (has no effect unless cpu_core_count is also set). | no|
| capacity_reservation_specification | Describes an instance's Capacity Reservation targeting option | no |
| enable_volume_tags |Whether to enable volume tags (if enabled it conflicts with root_block_device tags)| no |
| root_block_device | Customize details about the root block device of the instance. See Block Devices below for details | no|
| ebs_block_device |Additional EBS block devices to attach to the instance | no|
| ebs_optimized |If true, the launched EC2 instance will be EBS-optimized|no|
|tags| A mapping of tags to assign to the resource except the default tags defined in the provider.tf | no |
| create_spot_instance |Depicts if the instance is a spot instance|no|
|spot_price |The maximum price to request on the spot market. Defaults to on-demand price| no |
| spot_type |If set to one-time, after the instance is terminated, the spot request will be closed. Default persistent | no|

Output values:

| value      | Description | 
| ----------- | ----------- |
|  id | a map of instance name -> instance id|
|  arn | a map of instance name -> instance arn|

## Folder layout
```
deploy/<your-environment>
├── ec2
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

this is an example for ec2/terragrunt.hcl
```

terraform {
  source = "git::https://gitlab.enterprise.com/common/terraform-modules.git//aws/ec2"
  ### you can stick to a specific version so any further module update won't impact your exisitng infra
  ##source = "git::https://gitlab.enterprise.com/common/terraform-modules.git//aws/ec2?ref=v0.2"
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
      }
    }
EOF
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

  ec2_instances = {
    "instance-test-1" =  {
       name = "instance-test-1"

       ami                    = "ami-xxxxxxxxxxxxxxxxx"
       instance_type          = "t2.micro"
       availability_zone      = "ap-southeast-1c"
       ## this is the name of your key pair
       #key_name               = "user1"
       monitoring             = true
       vpc_security_group_ids = ["sg-xxxxxxxxxxxxxxxxx"]  ### you can use dependency.security_group.outputs.id["your_security_group_name"] if you use security-group module to create them
       subnet_id              = "subnet-xxxxxxxxxxxxxxxxx"
  
       default_tags           = dependency.default-tags.outputs.tags
       tags = { mykey = "myvalue"}
    }
    "instance-test-2" =  {
       name = "instance-test-2"

       ami                    = "ami-xxxxxxxxxxxxxxxxx"
       instance_type          = "t2.micro"
       availability_zone      = "ap-southeast-1c"
       ## this is the name of your key pair
       #key_name               = "user1"
       monitoring             = true
       vpc_security_group_ids = ["sg-xxxxxxxxxxxxxxxxx"]
       subnet_id              = "subnet-00861f8aee4829082"
       enable_volume_tags     = true
       ebs_block_device = [
        { 
        device_name = "/dev/xvdbb"
        volume_size = "2"
        volume_type = "gp3"
        }
       ]
       default_tags           = dependency.default-tags.outputs.tags
       tags = { mykey = "myvalue"}
    }
  }
}
```



