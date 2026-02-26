resource "helm_release" "jenkins" {
  name             = "jenkins"
  namespace        = var.namespace
  create_namespace = true
  repository       = "https://charts.jenkins.io"
  chart            = "jenkins"
  version          = var.chart_version

  values = [file("${path.module}/values.yaml")]

  timeout         = 3600
  wait            = true
  cleanup_on_fail = true
}