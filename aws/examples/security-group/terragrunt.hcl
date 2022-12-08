terraform {
  source = "../..//module/security-group"
  ##source = "git::https://gitlab.enterprise.com/common/terraform-modules.git//aws/security-group"

}

include {
  path = find_in_parent_folders()
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

    security_groups = {
      "security-name-1" = {
        name = "security-name-1"
        description= "test 1"
        vpc_id = "vpc-xxxxxxxxxxxxxx"
        ## must use default_tags here for cost center purpose
        default_tags = dependency.default-tags.outputs.tags
        tags = {
        ### define your own key-value tag here
                mykey = "myvalue"
        }
        ingress = {
            rule1 = {
              description = "test"
              from_port = 5432
              to_port = 5432
              protocol = "tcp"
              cidr_blocks = "10.0.0.0/16"
            } 
            rule2 = {
              from_port = 5432
              to_port = 5432
              protocol = "udp"
              cidr_blocks = "10.0.0.0/16"
            }
        }
           
      }
  
    }
}