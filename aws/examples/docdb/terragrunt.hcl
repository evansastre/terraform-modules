terraform {
  source = "../..//module/docdb"
}

include root {
  path = find_in_parent_folders()
  expose = true
}


dependency "midware-env" {
  config_path  = "../midware-env"
  mock_outputs = {
    aws_docdb_cluster_parameter_group-docdb-paragroup = "temporary-aws_docdb_cluster_parameter_group-docdb-paragroup",
    aws_db_subnet_group_name = { db-subnet-group-2 : "temporary-aws_db_subnet_group"}
  }
}

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

  docdb_clusters = {
    "crex" = {
      db_name = "crex"
      db_subnet_group_name            = dependency.midware-env.outputs.aws_db_subnet_group_name["db-subnet-group-2"]
      db_cluster_parameter_group_name = dependency.midware-env.outputs.aws_docdb_cluster_parameter_group-docdb-paragroup
      vpc_id = include.root.inputs.vpc_id
      vpc_security_group_ids = ["sg-xxxxxxxxxxxxxxx"]
      default_tags             = dependency.default-tags.outputs.tags
      instance_count           = 1
      vault_path            = "kv-v2/dba"
      tags = {
        "db_app"        = "bus2" 
        "db_apptype"     = "N/A" 
        "db_class"       = "db.r6g.large"
        "db_comments"    = "" 
        "db_dba"         = "dba1" 
        "db_devowner"    = "dba1"
        "db_env"         = "stage" 
        "db_level"       = "2" 
        "db_module"      = "crex" 
        "db_provider"    = "awscloudb"
        "db_region"      = "ap-southeast-1" 
        "db_usagestatus" = "using" 

      }
    }
  }
}
