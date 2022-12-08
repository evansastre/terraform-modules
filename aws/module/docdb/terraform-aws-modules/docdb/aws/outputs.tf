output "docdb_security_group_id" {
  value = try(aws_security_group.this[0].id, null)
  description = "Security group id for this docdb"
}


output "id" {
  value = aws_docdb_cluster.this.id
  description = "id for this docdb"
}

output "arn" {
  value = aws_docdb_cluster.this.arn
  description = "arn for this docdb"
}

output "tags_all" {
  value = aws_docdb_cluster.this.tags_all
  
}