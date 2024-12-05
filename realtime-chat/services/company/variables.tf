variable "vpc_cidr_block" {
  description = "The CIDR block for the company chat service"
  type        = string
  sensitive   = false
}

variable "availability_zones" {
  description = "The availability zones for the company chat service"
  type        = list(string)
  sensitive   = false
}


variable "public_subnet_count" {
  description = "The number of public subnets to create"
  type        = number
  sensitive   = false
}


variable "private_subnet_count" {
  description = "The number of public subnets to create"
  type        = number
  sensitive   = false
}

variable "environment" {
  description = "The environment for the company chat service"
  type        = string
  sensitive   = false
}

variable "project_name" {
  description = "The name of the project"
  type        = string
  sensitive   = false

}