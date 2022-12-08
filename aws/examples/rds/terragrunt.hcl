terraform {
  source = "../../module//rds"
}

include root {
  path = find_in_parent_folders()
  expose = true
}

dependency "midware-env" {
  config_path  = "../midware-env"
  mock_outputs = {
    aws_rds_cluster_parameter_group-pg12-paragroup = "temporary-aws_rds_cluster_parameter_group-pg12-paragroup",
    aws_db_parameter_group-pg12-paragroup = "temporary-aws_db_parameter_group-pg12-paragroup",
    aws_rds_cluster_parameter_group-mysql-paragroup = "temporary-aws_rds_cluster_parameter_group-mysql-paragroup",
    aws_docdb_cluster_parameter_group-docdb-paragroup = "temporary-aws_docdb_cluster_parameter_group-docdb-paragroup",
    aws_db_subnet_group_name = { "db-subnet-group-1" = "temporary-aws_db_subnet_group"}
    aws_elasticache_subnet_group = "temporary-aws_elasticache_subnet_group"
  }
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

dependency "security-group"{
    config_path  = "../security-group"
    mock_outputs = {
      id = {
        "security-name-1" = "sg-xxxxxxxxxxxxxx"
      }
    }
}


inputs = {

  rds_clusters = {
    aip = {
      db_name = "aip"
      engine_version = "12.8"
      db_subnet_group_name            = dependency.midware-env.outputs.aws_db_subnet_group_name["db-subnet-group-1"]
      db_cluster_parameter_group_name = dependency.midware-env.outputs.aws_rds_cluster_parameter_group-pg12-paragroup
      db_parameter_group_name         = dependency.midware-env.outputs.aws_db_parameter_group-pg12-paragroup
      publicly_accessible = false
      instance_class = "db.r6g.large"
      vault_path  = "secrets/dba"
      vpc_security_group_ids = [dependency.security-group.outputs.id["security-name-1"]]
      create_monitoring_role = false
      ## monitoring_role_arn = <this will be created by IS IAM manager>
      monitoring_role_arn = "arn:aws:iam::123456789012:role/RDSEnhancedMonitoringRole"
      monitoring_interval = 60
      enabled_cloudwatch_logs_exports = ["postgresql"]
      default_tags             = dependency.default-tags.outputs.tags
    

      tags = {
        "environment"    = try(include.root.inputs.env, null)
        "region"         = try(include.root.inputs.region, null)
        "product_line"   = try(include.root.inputs.product_line, null)
        "db_app"         = "bus2" 
        "db_apptype"     = "oltp"
        "db_class"       = "db.r6g.large"
        "db_comments"    = ""
        "db_dba"         = "dba1" 
        "db_devowner"    = "dba1"
        "db_env"         = "stage" 
        "db_level"       = "2" 
        "db_module"      = "aip" 
        "db_provider"    = "awscloudb"
        "db_region"      = "ap-southeast-1" 
        "db_usagestatus" = "using" 
      }
    }
  }


}

