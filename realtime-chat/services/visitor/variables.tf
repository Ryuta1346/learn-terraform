variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
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

variable "availability_zones" {
  description = "The availability zones for the company chat service"
  type        = list(string)
  sensitive   = false
}
