variable "namespace" {
  type        = string
  default     = "jenkins"
  description = "Namespace for Jenkins"
}

variable "chart_version" {
  type        = string
  default     = "5.8.7"
  description = "Jenkins Helm chart version"
}
