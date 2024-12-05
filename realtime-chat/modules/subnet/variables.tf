variable "availability_zones" {
  description = "The availability zones for the VPC"
  type        = list(string)
  sensitive   = false
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
  sensitive   = false
}

variable "cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  sensitive   = false
}

variable "subnet_count" {
  description = "The number of public subnets to create"
  type        = number
  sensitive   = false
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

variable "map_public_ip_on_launch" {
  description = "Whether to map public IP on launch"
  type        = bool
  sensitive   = false
  default     = false
}

# variable "route_table_id" {
#   description = "The ID of the route table"
#   type        = string
#   sensitive   = false
# }