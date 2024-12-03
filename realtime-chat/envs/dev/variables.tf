variable "environment" {
  description = "The environment in which the resources will be created"
  type        = string
  sensitive   = false
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  sensitive   = false
}

variable "availability_zones" {
  description = "The availability zones for the VPC"
  type        = list(string)
  sensitive   = false
}