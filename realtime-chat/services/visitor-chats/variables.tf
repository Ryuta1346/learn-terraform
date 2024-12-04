variable "visitor_chat_vpc_id" {
  description = "The VPC ID for the visitor chat service"
  type        = string
  sensitive   = false
}

variable "visitor_chat_public_subnets" {
  description = "The public subnets for the visitor chat service"
  type        = list(string)
  sensitive   = false
}

variable "environment" {
  description = "The environment for the visitor chat service"
  type        = string
  sensitive   = false
}