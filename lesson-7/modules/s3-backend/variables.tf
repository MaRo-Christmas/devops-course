variable "bucket_name" {
  type = string
}

variable "dynamodb_table" {
  type = string
}

variable "enable_versioning" {
  type    = bool
  default = true
}
