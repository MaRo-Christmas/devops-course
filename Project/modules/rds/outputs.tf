output "subnet_group_name" {
  value       = aws_db_subnet_group.this.name
  description = "DB subnet group name"
}

output "security_group_id" {
  value       = aws_security_group.this.id
  description = "DB security group id"
}

output "db_port" {
  value       = local.db_port
  description = "DB port"
}

# RDS instance outputs
output "rds_instance_endpoint" {
  value       = var.use_aurora ? null : aws_db_instance.this[0].endpoint
  description = "RDS instance endpoint (if use_aurora=false)"
}

output "rds_instance_address" {
  value       = var.use_aurora ? null : aws_db_instance.this[0].address
  description = "RDS instance address (if use_aurora=false)"
}

# Aurora outputs
output "aurora_cluster_endpoint" {
  value       = var.use_aurora ? aws_rds_cluster.this[0].endpoint : null
  description = "Aurora cluster endpoint (writer)"
}

output "aurora_reader_endpoint" {
  value       = var.use_aurora ? aws_rds_cluster.this[0].reader_endpoint : null
  description = "Aurora reader endpoint"
}