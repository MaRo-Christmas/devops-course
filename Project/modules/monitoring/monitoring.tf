resource "helm_release" "kps" {
  name             = "monitoring"
  namespace        = var.namespace
  create_namespace = true
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  version          = var.chart_version

  values = [file("${path.module}/values.yaml")]

  timeout = 3600
  wait    = true
  atomic  = false
}