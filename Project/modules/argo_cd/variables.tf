variable "namespace" {
  type        = string
  default     = "argocd"
  description = "Namespace for Argo CD"
}

variable "chart_version" {
  type        = string
  default     = "7.6.12"
  description = "Argo CD Helm chart version"
}