output "cluster_main_endpoint_map" {
  description = "RDS Cluster's write endpoint"
  value       = { 
    for rds in module.rds-aurora:
      rds.cluster_id => rds.cluster_endpoint
  }
}

output "cluster_reader_endpoint" {
  description = "RDS Cluster's read endpoint"
  value       = {
    for rds in module.rds-aurora:
    rds.cluster_id => rds.cluster_reader_endpoint
  }
}

output "rds_db_security_group_id" {
  description = "RDS cluster instances' security group id"
  value = { 
    for rds in module.rds-aurora:
      rds.cluster_id => rds.security_group_id
  }
}