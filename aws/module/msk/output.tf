# security group id
output "msk_security_group_id" {
  value = aws_security_group.this.id
  description = "Security group id for this msk"
}