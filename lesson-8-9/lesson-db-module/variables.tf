variable "aws_region" {
  type        = string
  default     = "eu-central-1"
  description = "AWS region"
}

variable "db_password" {
  type        = string
  sensitive   = true
  description = "Master password for RDS/Aurora"
}