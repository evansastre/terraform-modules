##### this is an exmaple for local testing purpose only ########
##### no s3 remote backend is used here ########################
##### Please use the s3 remote state configuration for prod ####


terraform {
  source = "../..//module/ecr"
  ##source = "git::https://gitlab.enterprise.com/common/terraform-modules.git//aws/ecr?ref=v0.1"
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

### this is to use the default_tags defined in the provider
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
  name                  = "beta"
  
  tags = merge(dependency.default-tags.outputs.tags,
    {}
  )

}