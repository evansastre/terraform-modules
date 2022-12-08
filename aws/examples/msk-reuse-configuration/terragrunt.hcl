terraform {
  source = "../..//module/msk"
  #source = "git::https://gitlab.enterprise.com/devops/terraform-modules.git//aws/module/msk?ref=v0.1"

}

include root {
  path = find_in_parent_folders()
  expose =true
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

  # please keep the name unique otherwise the secret createion will be failed(cannot recreate the secret with the same name in 7 days)
  name                  = "beta3"
  client_subnets  = [
    "subnet-xxxxxxxxxxxxxxxxx",
    "subnet-xxxxxxxxxxxxxxxxx",
    "subnet-xxxxxxxxxxxxxxxxx"
  ]

  msk_instance_type   = "kafka.m5.large"
  ebs_volume_size     = 1

### reuse existing msk config
  ## create_msk_configuration = false
  existing_msk_configuration_name = "demo-sg-bus2-msk"

  default_tags = dependency.default-tags.outputs.tags
  tags = {
    additional_key: "myvalue"
  }
}
