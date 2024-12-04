variable "security_group_name" {
  description = "The name of the security group"
  type        = string
  sensitive   = false

}



variable "vpc_id" {
  description = "The ID of the Chat VPC"
  type        = string
  sensitive   = false
}

variable "environment" {
  description = "The environment for the Visitor's Chat service"
  type        = string
  sensitive   = false
}

variable "project_name" {
  description = "The name of the project"
  type        = string
  sensitive   = false
}