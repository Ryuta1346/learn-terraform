variable "visitor_vpc_cidr_block" {
  description = "The CIDR block for the Visitor's VPC"
  type        = string
  sensitive   = false
}

variable "visitor_public_subnet_count" {
  description = "The number of public subnets for the Visitor's VPC"
  type        = number
  sensitive   = false
}

variable "visitor_private_subnet_count" {
  description = "The number of private subnets for the Visitor's VPC"
  type        = number
  sensitive   = false

}

variable "company_vpc_cidr_block" {
  description = "The CIDR block for the Company's VPC"
  type        = string
  sensitive   = false
}

variable "company_public_subnet_count" {
  description = "The number of public subnets for the Visitor's VPC"
  type        = number
  sensitive   = false
}


variable "company_private_subnet_count" {
  description = "The number of private subnets for the Visitor's VPC"
  type        = number
  sensitive   = false

}

variable "shared_vpc_cidr_block" {
  description = "The CIDR block for the Shared's VPC"
  type        = string
  sensitive   = false
}

variable "availability_zones" {
  description = "The availability zones for the VPC"
  type        = list(string)
  sensitive   = false
}

variable "project_name" {
  description = "The name of the project"
  type        = string
  sensitive   = false

}