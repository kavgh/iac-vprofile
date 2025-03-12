variable "shared_config_files" {
  description = "Paths to AWS config files"
  type = list(string)
  default = [ "~/.aws/config" ]
}

variable "shared_credentials_files" {
  description = "Paths to AWS credentials files"
  type = list(string)
  default = [ "~/.aws/credentials" ]
}

variable "profile" {
  description = "Describe which profile to use for provisioning AWS resources"
  type = string
  default = "default"
}

