variable "visitor_chat_vpc_id" {
  description = "The ID of the Visitor's Chat VPC"
  type        = string
  sensitive   = false
}

variable "environment" {
  description = "The environment for the Visitor's Chat service"
  type        = string
  sensitive   = false
}