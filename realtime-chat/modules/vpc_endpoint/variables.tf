variable "id" {
  description = "The VPC endpoint ID"
  type        = string
  sensitive   = false
}

variable "vpc_id" {
  description = "The VPC ID"
  type        = string
  sensitive   = false
}

variable "security_group_ids" {
  description = "The security group IDs"
  type        = list(string)
  sensitive   = false
}

variable "subnet_ids" {
  description = "The subnet IDs"
  type        = list(string)
  sensitive   = false
}

variable "service_name" {
  description = "The service name"
  type        = string
  sensitive   = false
}

variable "endpoint_type" {
  description = "The endpoint type"
  type        = string
  sensitive   = false
  default     = "Interface"
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