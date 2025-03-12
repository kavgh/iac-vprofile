provider "aws" {
  profile = var.profile
  shared_config_files = var.shared_config_files
  shared_credentials_files = var.shared_credentials_files
}

module "vpc" {
  source = "./modules/vpc"
}