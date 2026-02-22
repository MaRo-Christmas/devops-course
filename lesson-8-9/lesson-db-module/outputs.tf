output "rds_endpoint" {
  description = "RDS endpoint"
  value       = module.rds.rds_instance_endpoint
}

output "rds_address" {
  description = "RDS address"
  value       = module.rds.rds_instance_address
}

output "db_security_group_id" {
  description = "DB security group id"
  value       = module.rds.security_group_id
}

output "db_subnet_group_name" {
  description = "DB subnet group name"
  value       = module.rds.subnet_group_name
}