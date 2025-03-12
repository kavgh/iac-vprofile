variable "tags" {
  description = "Tags to associate with"
  type = map(string)
  default = {}
}

variable "cidr_block" {
  description = "CIDR block for VPC"
  type = string
  default = "10.13.2.0/16"
}

variable "nos" {
  description = "The number of each subnet (private and public) to create"
  type = number
  default = 2
}