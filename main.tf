locals {
  tags = { Name = "GitOps" }
}

provider "aws" {
  profile                  = var.profile
  shared_config_files      = var.shared_config_files
  shared_credentials_files = var.shared_credentials_files
}

module "vpc" {
  source = "./modules/vpc"

  tags = local.tags
}

module "eks" {
  source = "./modules/eks"

  subnet_ids = module.vpc.public_subnet_ids
  vpc_id     = module.vpc.vpc_id

  tags = local.tags
}