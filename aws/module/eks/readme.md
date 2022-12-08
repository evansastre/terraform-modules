# EKS Module

You can use this module to create one or more EKS clusters. 


## Argument reference

Input

| Field      | Description | Required|
| ----------- | ----------- |---------|
| cluster_name | seks cluster name  |  yes |
| vpc_id  |  vpc id | yes|
| subnet_ids  |  ids of subnets| yes|
| cluster_version  |  k8s version: default 1.21 | yes|
| eks_managed_node_groups| list of managed node groups block|  yes|
| cluster_endpoint_public_access | allow this cluster to be access publically or not: default false| no |
| instance_types | instance type: default - c5.4xlarge | no|
| iam_role_additional_policies| additional policy for the cluster role: default []| no|
| default_tags | default tags must be provided | yes|



## Folder layout
```
deploy/<your-environment>
├── eks
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

this is an example for eks/terragrunt.hcl
```
terraform {
  source = "git::https://gitlab.enterprise.com/common/terraform-modules.git//aws/eks"
  ### ou can stick to a specific version so any further module update won't impact your exisitng infra
  # source = "git::https://gitlab.enterprise.com/common/terraform-modules.git//aws/eks?ref=v0.2"
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
        cluster = "wf"
      }
    }
}


locals {
  ## if you need a specific ami
  eks_node_ami_id = "ami-xxxxxxxxxxxxxxxxx"
}

inputs = {

  eks_clusters = {

    ## cluster 1
    test-sg-demo = {
      cluster_name = "test-sg-demo"
      
      ## default_tags for the EKS Cluster
      default_tags = dependency.default-tags.outputs.tags
      ## diable public access by default
      # cluster_endpoint_public_access = true

      subnet_ids = [
        "subnet-077d6debdd43749a0",
        "subnet-01be31d2457a87e50",
        "subnet-00861f8aee4829082"
      ]
      vpc_id = "vpc-0308080ea4774ad33"
      
      eks_managed_node_groups = {
        gateway = {
          min_size     = 2
          max_size     = 2
          desired_size = 2

          capacity_type = "ON_DEMAND"
          ## ssh key pair
          key_name = "eks-test"
          instance_types = ["t3.small"]
          update_config = {
            max_unavailable_percentage = 25
          }

          labels = {
            apptier     = "gateway"
          }
          ## you must provide the EC2 tags for node group, otherwise it will be rejected by AWS SCP policies
          tags = dependency.default-tags.outputs.tags
        }
      }
    }
  }

}
```



