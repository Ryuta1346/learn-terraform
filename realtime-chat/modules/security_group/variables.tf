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