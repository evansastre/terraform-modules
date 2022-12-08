
##### this is an exmaple for local testing purpose only ########
##### no s3 remote backend is used here ########################
##### Please use the s3 remote state configuration for prod ####

#remote_state {
#  backend = "s3"
#  generate = {
#    path      = "backend.tf"
#    if_exists = "overwrite"
#  }
#  config = {
#    bucket         = "s3-aws-org-test-tf-state"
#    key            = "${path_relative_to_include()}/terraform.tfstate"
#    region         = "ap-southeast-1"
#    encrypt        = true
#  }
#}

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
        vault = {
          source = "hashicorp/vault"
        }
      }
    }
EOF
}

generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
provider vault{}
provider "aws" {
  region = "ap-southeast-1"
  default_tags {
    tags = {
      school = "bus2"
      project = "bus2"
      subproject = "null"
      envir = "demo"
      contact = "contact"
      }

    }
 }
EOF
}

inputs = {
  region = "sg"
  env = "demo"
  product_line = "bus2"

  all_stage_password = "this-is-just-a-demo"
  ## demo vpc
  vpc_id = "vpc-xxxxxxxxxxxx"
}