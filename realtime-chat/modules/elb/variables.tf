variable "vpc_id" {
  description = "The ID of the Visitor's Chat VPC"
  type        = string
  sensitive   = false
}

variable "alb_sg_id" {
  description = "The ID of the Visitor's Chat ALB Security Group"
  type        = string
  sensitive   = false
}

variable "public_subnet_id" {
  description = "The ID of the Visitor's Chat Public Subnet"
  type        = string
  sensitive   = false
}

variable "environment" {
  description = "The environment for the Visitor's Chat service"
  type        = string
  sensitive   = false
}