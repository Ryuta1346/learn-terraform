variable "vpc_id" {
  description = "The VPC ID for the service"
  type        = string
  sensitive   = false
}

variable "public_subnets" {
  description = "The public subnets for the service"
  type        = list(string)
  sensitive   = false
}

variable "environment" {
  description = "The environment for the service"
  type        = string
  sensitive   = false
}