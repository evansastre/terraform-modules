
terraform {
  source = "../..//module/ec2"
  ##source = "git::https://gitlab.enterprise.com/common/terraform-modules.git//aws/ec2"
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

  ec2_instances = {
    "instance-test-1" =  {
       name = "instance-test-1"

       ami                    = "ami-xxxxxxxxxxxxxxxxx"
       instance_type          = "t2.micro"
       availability_zone      = "ap-southeast-1c"
       ## this is the name of your key pair
       #key_name               = "user1"
       monitoring             = true
       vpc_security_group_ids = ["sg-xxxxxxxxxxxxxxxxx"]
       subnet_id              = "subnet-xxxxxxxxxxxxxxxxx"
  
       default_tags           = dependency.default-tags.outputs.tags
       tags = { 
        OS = "Amazon linux 2"
        }

    }
  }
}