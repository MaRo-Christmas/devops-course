variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "cluster_version" {
  type        = string
  description = "EKS Kubernetes version"
  default     = "1.29"
}

variable "vpc_id" { type = string }

variable "private_subnet_ids" { type = list(string) }
variable "public_subnet_ids"  { type = list(string) }

variable "desired_size" { type = number }
variable "min_size"     { type = number }
variable "max_size"     { type = number }

variable "instance_types" {
  type        = list(string)
  description = "Instance types for managed node group"
  default     = ["t3.micro"]
}