variable "region" {
  description = "AWS region where to deploy infrastracture"
  type        = string
  default     = "us-east-2"
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster to deploy"
  type = string
  default = "vrpofile-eks"
}