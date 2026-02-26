output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to EKS control plane"
  value       = module.eks.cluster_security_group_id
}
