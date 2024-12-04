variable "visitor_vpc_cidr_block" {
  description = "The CIDR block for the Visitor's VPC"
  type        = string
  sensitive   = false
}

variable "company_vpc_cidr_block" {
  description = "The CIDR block for the Company's VPC"
  type        = string
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