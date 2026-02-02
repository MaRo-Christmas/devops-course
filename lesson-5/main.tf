terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "s3_backend" {
  source = "./modules/s3-backend"

  bucket_name       = var.tf_state_bucket_name
  dynamodb_table    = var.tf_lock_table_name
  enable_versioning = true
}

module "vpc" {
  source = "./modules/vpc"

  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  azs                  = var.azs
  project_name         = var.project_name
}

module "ecr" {
  source = "./modules/ecr"

  repository_name = "${var.project_name}-repo"
  scan_on_push    = true
  mutable_tags    = true
}