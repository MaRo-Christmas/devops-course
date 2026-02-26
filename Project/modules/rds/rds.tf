resource "aws_db_instance" "this" {
  count = var.use_aurora ? 0 : 1

  identifier = "${local.name_prefix}-instance"

  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage = var.allocated_storage
  storage_type      = var.storage_type
  storage_encrypted = var.storage_encrypted
  kms_key_id        = var.kms_key_id

  db_name  = var.db_name
  username = var.username
  password = var.password
  port     = local.db_port

  multi_az = var.multi_az

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]

  parameter_group_name = aws_db_parameter_group.instance[0].name

  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window

  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${local.name_prefix}-final-${replace(timestamp(), "[: TZ-]", "")}"

  publicly_accessible = var.publicly_accessible

  apply_immediately = var.apply_immediately

  tags = local.common_tags
}