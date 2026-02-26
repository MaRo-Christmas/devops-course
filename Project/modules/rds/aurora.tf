locals {
  aurora_engine = var.engine == "postgres" ? "aurora-postgresql" : "aurora-mysql"
}

resource "aws_rds_cluster" "this" {
  count = var.use_aurora ? 1 : 0

  cluster_identifier = "${local.name_prefix}-cluster"

  engine         = local.aurora_engine
  engine_version = var.engine_version

  database_name   = var.db_name
  master_username = var.username
  master_password = var.password
  port            = local.db_port

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]

  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.cluster[0].name

  storage_encrypted = var.storage_encrypted
  kms_key_id        = var.kms_key_id

  backup_retention_period      = var.backup_retention_period
  preferred_backup_window      = var.backup_window
  preferred_maintenance_window = var.maintenance_window

  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${local.name_prefix}-final-${replace(timestamp(), "[: TZ-]", "")}"

  apply_immediately = var.apply_immediately

  tags = local.common_tags
}

resource "aws_rds_cluster_instance" "writer" {
  count = var.use_aurora ? 1 : 0

  identifier         = "${local.name_prefix}-writer-1"
  cluster_identifier = aws_rds_cluster.this[0].id

  instance_class = var.instance_class
  engine         = local.aurora_engine
  engine_version = var.engine_version

  db_subnet_group_name = aws_db_subnet_group.this.name
  publicly_accessible  = var.publicly_accessible

  tags = local.common_tags
}