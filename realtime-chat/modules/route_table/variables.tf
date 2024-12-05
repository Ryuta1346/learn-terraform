variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
  sensitive   = false
}

variable "routes" {
  type = list(object({
    cidr_block     = string
    gateway_id     = optional(string)
    nat_gateway_id = optional(string)
    # transit_gateway_id  = optional(string)
  }))
}

variable "environment" {
  description = "The environment for the VPC"
  type        = string
  sensitive   = false
}

variable "project_name" {
  description = "The name of the project"
  type        = string
  sensitive   = false

}