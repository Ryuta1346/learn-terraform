variable "environment" {
  description = "The environment for the VPC"
  type        = string
  sensitive   = false
}

variable "gateway_name" {
  description = "The name of the internet gateway"
  type        = string
  sensitive   = false
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
  sensitive   = false

}

variable "project_name" {
  description = "The name of the project"
  type        = string
  sensitive   = false

}