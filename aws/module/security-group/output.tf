output "id" {
  description = "id of the security group"
  value       = {
    for sg in aws_security_group.this :
      sg.name => sg.id
  }
}