variable "company_chat_vpc_id" {
  description = "The VPC ID for the company chat service"
  type        = string
  sensitive   = false
}

variable "company_chat_public_subnets" {
  description = "The public subnets for the company chat service"
  type        = list(string)
  sensitive   = false
}

variable "environment" {
  description = "The environment for the company chat service"
  type        = string
  sensitive   = false
}