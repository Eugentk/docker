variable "region" {
  description = "Please Enter AWS region"
  default     = "eu-central-1" # Frankfurt region
}
# EC2 Variables
variable "servers_count" {
  description = "Please Enter count"
  default     = "3"
}
variable "instance_type" {
  description = "Please Enter Instance Type"
  default     = "t3.small"
}
variable "volume_size" {
  description = "Please Enter volume size"
  default     = "8"
}
variable "ssh_key_name" {
  description = "Please Enter ssh key name to connect for ssh"
  default     = "datadog"
}
variable "public_key_path" {
  description = "Please choose public key"
  default     = "./public_key"
}
# VPC Variables
variable "vpc_cidr" {
  description = "CIDR for the whole VPC"
  default     = "172.10.0.0/16"
}
variable "subnet_public" {
  description = "CIDR for the Public subnet"
  type        = list(any)
  default     = ["172.10.0.0/24", "172.10.1.0/24", "172.10.2.0/24"]
}
variable "main_tags" {
  description = "Common tags"
  type        = map(string)
  default = {
    Maintainer : "datadog"
    Project : "Terraform datadog"
    Environment : "datadog"
  }
}