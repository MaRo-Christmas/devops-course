output "namespace" {
  value = var.namespace
}

output "initial_admin_password" {
  value     = try(nonsensitive(base64decode(data.kubernetes_secret.argocd_admin.data["password"])), null)
  sensitive = true
}

data "kubernetes_secret" "argocd_admin" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = var.namespace
  }
  depends_on = [helm_release.argocd]
}