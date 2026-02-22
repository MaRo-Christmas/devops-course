locals {
  name_prefix = "${var.project}-${var.environment}-${var.name}"

  default_port = var.engine == "mysql" ? 3306 : 5432

  db_port = coalesce(var.port, local.default_port)

  common_tags = merge(var.tags, {
    Project     = var.project
    Environment = var.environment
    Module      = "rds"
  })
}

resource "aws_db_subnet_group" "this" {
  name       = "${local.name_prefix}-db-subnets"
  subnet_ids = var.subnet_ids

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-db-subnets"
  })
}

resource "aws_security_group" "this" {
  name        = "${local.name_prefix}-db-sg"
  description = "DB access for ${local.name_prefix}"
  vpc_id      = var.vpc_id

  ingress {
    description     = "DB access"
    from_port       = local.db_port
    to_port         = local.db_port
    protocol        = "tcp"
    cidr_blocks     = var.allowed_cidr_blocks
    security_groups = var.allowed_security_group_ids
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-db-sg"
  })
}

# Parameter Group для звичайного RDS instance (Postgres/MySQL)
resource "aws_db_parameter_group" "instance" {
  count = var.use_aurora ? 0 : 1

  name   = "${local.name_prefix}-pg"
  family = var.parameter_group_family

  parameter {
    name         = "max_connections"
    value        = tostring(var.db_params.max_connections)
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "log_statement"
    value        = var.db_params.log_statement
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "work_mem"
    value        = tostring(var.db_params.work_mem)
    apply_method = "pending-reboot"
  }

  tags = local.common_tags
}

resource "aws_rds_cluster_parameter_group" "cluster" {
  count = var.use_aurora ? 1 : 0

  name   = "${local.name_prefix}-cpg"
  family = var.parameter_group_family

  parameter {
    name         = "max_connections"
    value        = tostring(var.db_params.max_connections)
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "log_statement"
    value        = var.db_params.log_statement
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "work_mem"
    value        = tostring(var.db_params.work_mem)
    apply_method = "pending-reboot"
  }

  tags = local.common_tags
}