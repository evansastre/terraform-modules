terraform {
  source = "${get_parent_terragrunt_dir()}/../module//elasticache"
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

dependency "midware-env"{
    config_path  = "../midware-env"
    mock_outputs = {
      aws_elasticache_subnet_group_name = { redis-subnet-group-1  = "example-elasticache-subnet-id"}
    }
}

dependency "security-group"{
    config_path  = "../security-group"
    mock_outputs = {
      id = {
        "security-name-1" = "sg-xxxxxxxx"
      }
    }
}

inputs = {
  redis_instances = {

    aip = {
      db_name                  = "aip"
      redis_subnet_group_name  = dependency.midware-env.outputs.aws_elasticache_subnet_group_name["redis-subnet-group-1"]
      vpc_id                   = "vpc-xxxxxxxx"
      default_tags             = dependency.default-tags.outputs.tags
      security_group_ids       = [dependency.security-group.outputs.id["security-name-1"]]
      vault_path               = "kv-v2/dba"
      tags = {
        "db_app"         = "bus2" 
        "db_apptype"     = "N/A"
        "db_class"       = "cache.r6g.large"
        "db_comments"    = ""
        "db_dba"         = "dba1" 
        "db_devowner"    = "dba1"
        "db_env"         = "stage" 
        "db_level"       = "2" 
        "db_module"      = "aip" 
        "db_provider"    = "awscloudb"
        "db_region"      = "ap-southeast-1" 
        "db_usagestatus" = "using" 
        "envir"          = "prod"
        "subproject"     = "aip"
      }
    }
  }
}
