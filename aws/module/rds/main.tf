
################################################################################
# Supporting Resources
################################################################################

resource "random_password" "master" {
  length  = 14
  special = false
}


module "rds-aurora" {
  for_each = var.rds_clusters

  source  = "./terraform-aws-modules/rds-aurora/aws"


  #name                   = join("-", ["aws-${var.region}-${var.product_line}", try(each.value.db_name, var.db_name),"${var.env}"])
  name                   = join("-", ["aws-${var.region}", try(each.value.db_name, var.db_name),"${var.env}"])
  #name                   = try(each.value.db_name, var.db_name)
  #database_name          = try(each.value.db_name, var.db_name)
  engine                 = try("aurora-${each.value.engine}", "aurora-${var.engine}")
  engine_version         = try(each.value.engine_version, var.engine_version)
  instance_class         = try(each.value.instance_class, var.instance_class )
  master_username = "enterprisedbaadmin"
  create_random_password = false
  vault_path = try(each.value.vault_path, null)
  master_password        = coalesce(var.all_stage_password, random_password.master.result)
 
  instances = try(each.value.instances, var.instances)

  deletion_protection    = coalesce(var.rds_cluster_deletion_protection, true)
  vpc_id                 = var.vpc_id
  db_subnet_group_name   = try(each.value.db_subnet_group_name, var.db_subnet_group_name)
  create_db_subnet_group = false
  vpc_security_group_ids = try(each.value.vpc_security_group_ids, null)
  publicly_accessible    = try(each.value.publicly_accessible, var.publicly_accessible)

  storage_encrypted            = true
  apply_immediately            = true
 
  copy_tags_to_snapshot        = true
  preferred_backup_window      = "17:00-20:00"
  backup_retention_period      = try(each.value.rds_cluster_backup_retention_period, 7)
  preferred_maintenance_window = "mon:03:00-mon:04:00"
  performance_insights_enabled = true
  performance_insights_retention_period = 7
  create_security_group        = try(each.value.create_security_group, var.create_security_group)

  ### Only SecurityIamManager is allowed to create IAM role/user in the AWS re-org design
  create_monitoring_role       = each.value.create_monitoring_role
  monitoring_role_arn          = try(each.value.monitoring_role_arn, null)
  monitoring_interval          = try(each.value.monitoring_interval, 60)
  db_cluster_parameter_group_name = try(each.value.db_cluster_parameter_group_name, var.db_cluster_parameter_group_name)
  db_parameter_group_name         = try(each.value.db_parameter_group_name, var.db_parameter_group_name)

  enabled_cloudwatch_logs_exports = try(each.value.enabled_cloudwatch_logs_exports, var.enabled_cloudwatch_logs_exports)
 
  default_tags = try(each.value.default_tags, null)
  tags = merge(each.value.tags, 
              { repo = try(each.value.default_tags["repo"],"")}, 
              { iac_managed_by = try(each.value.default_tags["iac_managed_by"],"terraform")}, 
              null)
}
