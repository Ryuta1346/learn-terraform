variable "shared_chat_private_aurora_sg_id" {
  description = "The ID of the private security group"
  type        = string
}

variable "shared_chat_private_elasticache_sg_id" {
  description = "The ID of the private security group"
  type        = string
}

variable "shared_chat_vpc_id" {
  description = "The ID of the Shared Chat VPC"
  type        = string
}

variable "visitor_vpc_cider_block" {
  description = "The CIDR block of the Visitor's Chat VPC"
  type        = string
}

variable "visitor_chat_vpc_id" {
  description = "The ID of the Visitor's Chat VPC"
  type        = string
}

variable "visitor_ecs_chat_sg_id" {
  description = "The ID of the Visitor's ECS security group"
  type        = string
}

variable "visitor_ecs_route_table_id" {
  description = "The ID of the Visitor's ECS route table"
  type        = string
}

variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "environment" {
  description = "The environment of the project"
  type        = string
}