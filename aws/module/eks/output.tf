output "arn" {
  description = "eks cluster arn"
  value       = {
    for eks in module.cluster:
    eks.cluster_id => eks.cluster_arn
  }
}

