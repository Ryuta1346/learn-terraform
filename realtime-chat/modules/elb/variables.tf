variable "elb_name" {
  description = "The name of the ELB"
  type        = string
  sensitive   = false

}

variable "load_balancer_type" {
  description = "The type of load balancer"
  type        = string
  sensitive   = false
  default     = "application"
}

variable "enable_deletion_protection" {
  description = "Whether to enable deletion protection"
  type        = bool
  sensitive   = false
  default     = true
}

variable "internal" {
  description = "Whether the ELB is internal"
  type        = bool
  sensitive   = false
  default     = false
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
  sensitive   = false
}

variable "alb_sg_id" {
  description = "The ID of the ALB Security Group"
  type        = string
  sensitive   = false
}

variable "subnet_ids" {
  description = "The IDs of the subnets"
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

variable "access_logs_enabled" {
  description = "Whether to enable access logs"
  type        = bool
  sensitive   = false
  default     = false
}