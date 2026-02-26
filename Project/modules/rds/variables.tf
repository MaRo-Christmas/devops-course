variable "project" {
  type        = string
  description = "Project name (used in naming/tags)"
}

variable "environment" {
  type        = string
  description = "Environment name (dev/stage/prod)"
}

variable "name" {
  type        = string
  description = "Module instance name (e.g. app-db)"
  default     = "db"
}

variable "use_aurora" {
  type        = bool
  description = "If true -> create Aurora Cluster. If false -> create single RDS instance."
  default     = false
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where DB will be deployed"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for DB subnet group"
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks allowed to connect to DB port"
  default     = []
}

variable "allowed_security_group_ids" {
  type        = list(string)
  description = "Security Group IDs allowed to connect to DB port"
  default     = []
}

variable "engine" {
  type        = string
  description = "DB engine: postgres or mysql (Aurora also uses these names in AWS provider)"
  default     = "postgres"

  validation {
    condition     = contains(["postgres", "mysql"], var.engine)
    error_message = "engine must be 'postgres' or 'mysql'."
  }
}

variable "engine_version" {
  type        = string
  description = "Engine version (optional). If null, AWS chooses default supported version."
  default     = null
}

variable "instance_class" {
  type        = string
  description = "Instance class for RDS instance or Aurora writer"
  default     = "db.t3.medium"
}

variable "multi_az" {
  type        = bool
  description = "Multi-AZ for RDS instance (ignored for Aurora cluster)"
  default     = false
}

variable "db_name" {
  type        = string
  description = "Database name"
  default     = "appdb"
}

variable "username" {
  type        = string
  description = "Master username"
}

variable "password" {
  type        = string
  description = "Master password"
  sensitive   = true
}

variable "port" {
  type        = number
  description = "Optional custom port. If null -> defaults by engine."
  default     = null
}

variable "parameter_group_family" {
  type        = string
  description = "Parameter group family (e.g. postgres16, aurora-postgresql16, mysql8.0, aurora-mysql8.0)"
}

variable "db_params" {
  type = object({
    max_connections = number
    log_statement   = string
    work_mem        = number
  })
  description = "Base DB parameters"
  default = {
    max_connections = 200
    log_statement   = "none"
    work_mem        = 4096
  }
}

# Storage settings (only for non-Aurora instance реально застосовуються повністю)
variable "allocated_storage" {
  type        = number
  description = "Allocated storage in GB (RDS instance only)"
  default     = 20
}

variable "storage_type" {
  type        = string
  description = "Storage type (gp2/gp3/io1) for RDS instance"
  default     = "gp3"
}

variable "storage_encrypted" {
  type        = bool
  description = "Enable storage encryption"
  default     = true
}

variable "kms_key_id" {
  type        = string
  description = "KMS Key ID for encryption (optional)"
  default     = null
}

variable "backup_retention_period" {
  type        = number
  description = "Backup retention in days"
  default     = 7
}

variable "backup_window" {
  type        = string
  description = "Backup window (e.g. 03:00-04:00)"
  default     = "03:00-04:00"
}

variable "maintenance_window" {
  type        = string
  description = "Maintenance window (e.g. sun:05:00-sun:06:00)"
  default     = "sun:05:00-sun:06:00"
}

variable "publicly_accessible" {
  type        = bool
  description = "Whether DB is publicly accessible"
  default     = false
}

variable "deletion_protection" {
  type        = bool
  description = "Enable deletion protection"
  default     = false
}

variable "skip_final_snapshot" {
  type        = bool
  description = "Skip final snapshot on destroy"
  default     = true
}

variable "apply_immediately" {
  type        = bool
  description = "Apply modifications immediately"
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Additional tags"
  default     = {}
}