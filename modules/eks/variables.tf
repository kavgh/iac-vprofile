variable "tags" {
  description = "Tags to associate with"
  type        = map(string)
  default = {}
}

variable "subnet_ids" {
  description = "List of subnet IDs to deploy EKS cluster"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID to associate with"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster to deploy"
  type = string
}