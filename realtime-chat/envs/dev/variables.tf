# variable "visitor_vpc_cidr_block" {
#   description = "The CIDR block for the Visitor's VPC"
#   type        = string
#   sensitive   = false
# }

# variable "company_vpc_cidr_block" {
#   description = "The CIDR block for the Company's VPC"
#   type        = string
#   sensitive   = false
# }

# variable "shared_vpc_cidr_block" {
#   description = "The CIDR block for the Shared's VPC"
#   type        = string
#   sensitive   = false
# }
variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  sensitive   = false
}

variable "region" {
  description = "The region for the VPC"
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

variable "environment" {
  description = "The environment for the VPC"
  type        = string
  sensitive   = false
}