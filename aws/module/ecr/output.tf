output "registry_id" {
  value = aws_ecr_repository.this.registry_id
  description = "registry id"
}


output "arn" {
  value = aws_ecr_repository.this.arn
  description = "registry arn"
}