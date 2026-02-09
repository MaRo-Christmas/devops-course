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

# Reuse the existing VPC from lesson-5 via remote state
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket
    key    = var.remote_state_key
    region = var.aws_region
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

  cluster_name = var.eks_cluster_name
  aws_region   = var.aws_region

  vpc_id             = data.terraform_remote_state.network.outputs.vpc_id
  private_subnet_ids = data.terraform_remote_state.network.outputs.private_subnet_ids
  public_subnet_ids  = data.terraform_remote_state.network.outputs.public_subnet_ids

  desired_size = var.node_desired_size
  min_size     = var.node_min_size
  max_size     = var.node_max_size

  instance_types = var.instance_types
}