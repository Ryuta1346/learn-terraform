variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  sensitive   = false
}

variable "availability_zones" {
  description = "The availability zones for the service"
  type        = list(string)
  sensitive   = false
}

variable "environment" {
  description = "The environment for the service"
  type        = string
  sensitive   = false
}

variable "project_name" {
  description = "The name of the project"
  type        = string
  sensitive   = false
}

variable "region" {
  description = "The region for the service"
  type        = string
  sensitive   = false
}

variable "chat_queue" {
  description = "The ARN of the visitor chat queue"
  type = object({
    id  = string
    arn = string
  })
  sensitive = false
}

variable "notification_queue" {
  description = "The ARN of the visitor notification queue"
  type = object({
    id  = string
    arn = string
  })
  sensitive = false
}

variable "company_vars" {
  description = "The variables for the company service"
  type = object({
    vpc_id             = string
    vpc_cider_block    = string
    ecs_route_table_id = string
    ecs_chat_sg_id     = string
  })
  sensitive = false
}

variable "visitor_vars" {
  description = "The variables for the visitor service"
  type = object({
    vpc_id             = string
    vpc_cider_block    = string
    ecs_route_table_id = string
    ecs_chat_sg_id     = string
  })
  sensitive = false
}

variable "cluster" {
  description = "The cluster configuration"
  type = object({
    cache_storage_max_gb = number
    ecpu_per_second_max  = number
    daily_snapshot_time  = optional(string)
    major_engine_version = string
    user_group_id        = optional(string)
    engine               = string
  })
}
