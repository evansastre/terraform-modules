output "id" {
  description = "The ID of the instance"
  value       = {
    for instance in module.ec2_instance:
      instance.tags_all["Name"] => instance.id
  }
}

output "arn" {
  description = "The ARN of the instance"
    value       = {
    for instance in module.ec2_instance:
      instance.tags_all["Name"] => instance.arn
  }
}


output "private_ip" {
  description = "The private_ip of the instance"
    value       = {
    for instance in module.ec2_instance:
      instance.tags_all["Name"] => instance.private_ip
  }
}

output "public_ip" {
  description = "The public_ip of the instance"
    value       = {
    for instance in module.ec2_instance:
      instance.tags_all["Name"] => instance.public_ip
  }
}