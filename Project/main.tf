terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

module "ecr" {
  source = "./modules/ecr"

  repository_name = var.ecr_repository_name
  scan_on_push    = true
  mutable_tags    = true
}

module "eks" {
  source = "./modules/eks"

  cluster_name    = var.eks_cluster_name
  cluster_version = "1.29" # або твоя змінна

  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids

  instance_types = var.instance_types

  min_size     = var.node_min_size
  max_size     = var.node_max_size
  desired_size = var.node_desired_size
}

module "rds" {
  source = "./modules/rds"

  project     = "devops-course"
  environment = "dev"
  name        = "app-db"

  use_aurora = false # true -> Aurora, false -> RDS instance

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids

  allowed_security_group_ids = [module.eks.cluster_security_group_id]
  allowed_cidr_blocks        = []

  engine         = "postgres"
  instance_class = "db.t3.medium"
  multi_az       = false

  db_name  = "appdb"
  username = "appuser"
  password = var.db_password

  parameter_group_family = "postgres17"

  db_params = {
    max_connections = 300
    log_statement   = "none"
    work_mem        = 4096
  }

  tags = {
    Owner = "Maryna"
  }
}

module "vpc" {
  source = "./modules/vpc"

  project_name         = var.project_name
  vpc_cidr             = var.vpc_cidr
  azs                  = var.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "jenkins" {
  count         = var.enable_addons ? 1 : 0
  source        = "./modules/jenkins"
  namespace     = "jenkins"
  chart_version = "5.8.7"
  depends_on    = [module.eks]
}

module "argo_cd" {
  count         = var.enable_addons ? 1 : 0
  source        = "./modules/argo_cd"
  namespace     = "argocd"
  chart_version = "7.6.12"
  depends_on    = [module.eks]
}

module "monitoring" {
  count         = var.enable_addons ? 1 : 0
  source        = "./modules/monitoring"
  namespace     = "monitoring"
  chart_version = "61.7.2"
  depends_on    = [module.eks]
}