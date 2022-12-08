
terraform {
  source = "../..//module/default-tags"
  ##source = "git::https://gitlab.enterprise.com/common/terraform-modules.git//aws/default-tags"
}

include root {
  path = find_in_parent_folders()
  expose = true
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
