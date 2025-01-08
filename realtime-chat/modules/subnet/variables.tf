variable "subnet_vars" {
  description = "values for subnet"
  type = list(object({
    id                      = string
    availability_zone       = string
    vpc_id                  = string
    cidr_block              = string
    map_public_ip_on_launch = bool
    is_private              = bool
  }))
}

variable "environment" {
  description = "The environment for the subnet"
  type        = string
  sensitive   = false
}

variable "project_name" {
  description = "The name of the project"
  type        = string
  sensitive   = false
}