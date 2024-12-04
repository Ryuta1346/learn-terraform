variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
  sensitive   = false
}

variable "internet_gateway_id" {
  description = "The ID of the internet gateway"
  type        = string
  sensitive   = false
}

variable "subnet_id" {
  description = "The ID of the subnet"
  type        = string
  sensitive   = false
}

variable "route_table_cidr_block" {
  description = "The CIDR block for the public route table"
  type        = string
  sensitive   = false
  default     = "0.0.0.0/0"
}

variable "environment" {
  description = "The environment for the VPC"
  type        = string
  sensitive   = false
}

variable "project_name" {
  description = "The name of the project"
  type        = string
  sensitive   = false

}