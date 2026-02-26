output "namespace" {
  value = var.namespace
}

output "admin_password" {
  value     = try(data.kubernetes_secret.jenkins_admin.data["jenkins-admin-password"], null)
  sensitive = true
}

data "kubernetes_secret" "jenkins_admin" {
  metadata {
    name      = "jenkins"
    namespace = var.namespace
  }
  depends_on = [helm_release.jenkins]
}