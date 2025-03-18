locals {
  tags = { Name = "GitOps" }
}

provider "aws" {
  region = var.region
}

module "vpc" {
  source = "./modules/vpc"

  tags = local.tags
}

module "eks" {
  source = "./modules/eks"

  cluster_name = var.eks_cluster_name
  subnet_ids = module.vpc.public_subnet_ids
  vpc_id     = module.vpc.vpc_id

  tags = local.tags
}