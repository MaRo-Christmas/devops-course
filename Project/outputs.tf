output "ecr_repository_url" {
  value = module.ecr.repository_url
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "jenkins_namespace" {
  value = var.enable_addons ? module.jenkins[0].namespace : null
}

output "argocd_namespace" {
  value = var.enable_addons ? module.argo_cd[0].namespace : null
}

output "monitoring_namespace" {
  value = var.enable_addons ? module.monitoring[0].namespace : null
}

output "jenkins_admin_password" {
  value     = var.enable_addons ? module.jenkins[0].admin_password : null
  sensitive = true
}

output "argocd_initial_admin_password" {
  value     = var.enable_addons ? module.argo_cd[0].initial_admin_password : null
  sensitive = true
}