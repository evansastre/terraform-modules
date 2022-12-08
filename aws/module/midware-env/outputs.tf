output "aws_rds_cluster_parameter_group-pg12-paragroup" {
  value = try(aws_rds_cluster_parameter_group.pg12-paragroup[0].name, null)
}

output "aws_db_parameter_group-pg12-paragroup" {
  value = try(aws_db_parameter_group.pg12-paragroup[0].name, null)
}

output "aws_rds_cluster_parameter_group-mysql-paragroup" {
  value = try(aws_rds_cluster_parameter_group.mysql-paragroup[0].name, null)
}

output "aws_db_parameter_group-mysql-paragroup" {
  value = try(aws_db_parameter_group.mysql-paragroup[0].name, null)
}

output "aws_docdb_cluster_parameter_group-docdb-paragroup" {
  value = try(aws_docdb_cluster_parameter_group.docdb-paragroup[0].name, null)
}

output "aws_msk_configuration_arn" {
  value = try(aws_msk_configuration.this[0].arn, null)
}

output "aws_db_subnet_group_name" {
    value       = {
    for db_subnet_group in aws_db_subnet_group.this :
      db_subnet_group.name => db_subnet_group.id
  }
}

output "aws_elasticache_subnet_group_name" {
    value       = {
    for elasticache_subnet_group in aws_elasticache_subnet_group.this :
      elasticache_subnet_group.name => elasticache_subnet_group.id
  }
}