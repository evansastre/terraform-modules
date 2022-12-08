# security group id
output "redisdb_security_group_id" {
  description = "Security group id for this redis"
  value       = { 
    for sg in aws_security_group.this:
      sg.name => sg.id
  }
}