variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "eu-central-1"
}

variable "project_name" {
  type        = string
  description = "Project name prefix for resource naming"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for VPC"
}

variable "azs" {
  type        = list(string)
  description = "Availability Zones list"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDRs for public subnets"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDRs for private subnets"
}

variable "remote_state_key" {
  type        = string
  description = "Key (path) to lesson-5 terraform state in the bucket"
  default     = "lesson-5/terraform.tfstate"
}

variable "eks_cluster_name" {
  type        = string
  description = "EKS cluster name"
  default     = "lesson-7-eks"
}

variable "ecr_repository_name" {
  type        = string
  description = "ECR repository name for Django image"
  default     = "django-app"
}

variable "node_desired_size" {
  type    = number
  default = 2
}
variable "node_min_size" {
  type    = number
  default = 2
}
variable "node_max_size" {
  type    = number
  default = 6
}
variable "instance_types" {
  type        = list(string)
  description = "Instance types for managed node group"
  default     = ["t3.medium"]

}

variable "db_password" {
  type        = string
  description = "Master password for RDS/Aurora"
  sensitive   = true
}

variable "enable_addons" {
  type    = bool
  default = true
}