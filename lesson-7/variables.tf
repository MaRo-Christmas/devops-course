variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "eu-central-1"
}

variable "remote_state_bucket" {
  type        = string
  description = "S3 bucket where lesson-5 state is stored"
  default     = "maro-lesson-5-tfstate-12345"
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
  default     = ["t3.micro"]

}
