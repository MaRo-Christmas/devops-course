variable "namespace" {
  type        = string
  default     = "monitoring"
  description = "Namespace for monitoring stack"
}

variable "chart_version" {
  type        = string
  default     = "61.7.2"
  description = "kube-prometheus-stack chart version"
}