variable "repository_name" {
  type = string
}

variable "scan_on_push" {
  type    = bool
  default = true
}

variable "mutable_tags" {
  type    = bool
  default = true
}
