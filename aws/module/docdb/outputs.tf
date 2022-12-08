output "id" {
  description = "The ID of the cluster"
  value       = {
    for cluster in module.docdb_cluster:
      cluster.tags_all["db_name"] => cluster.id
  }
}

output "arn" {
  description = "The ARN of the cluster"
    value       = {
    for cluster in module.docdb_cluster:
      cluster.tags_all["db_name"] => cluster.arn
  }
}
