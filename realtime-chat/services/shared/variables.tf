variable "vpc_id" {
  description = "The VPC ID for the shared service"
  type        = string
  sensitive   = false
}

variable "public_subnets" {
  description = "The public subnets for the shared service"
  type        = list(string)
  sensitive   = false
}

variable "private_subnets" {
  description = "The private subnets for the shared service"
  type        = list(string)
  sensitive   = false

}

variable "environment" {
  description = "The environment for the shared service"
  type        = string
  sensitive   = false
}