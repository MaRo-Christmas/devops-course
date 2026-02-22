module "rds" {
  source = "../modules/rds"

  project     = "devops-course"
  environment = "dev"
  name        = "app-db"

  use_aurora = true

  vpc_id     = data.terraform_remote_state.network.outputs.vpc_id
  subnet_ids = data.terraform_remote_state.network.outputs.private_subnet_ids

  allowed_security_group_ids = []
  allowed_cidr_blocks        = [data.aws_vpc.selected.cidr_block]

  engine         = "postgres"
  engine_version = "17"
  instance_class = "db.t3.medium"
  multi_az       = false

  db_name  = "appdb"
  username = "appuser"
  password = var.db_password

  parameter_group_family = "aurora-postgresql17"

  db_params = {
    max_connections = 300
    log_statement   = "none"
    work_mem        = 4096
  }

  tags = {
    Owner = "Maryna"
  }
}