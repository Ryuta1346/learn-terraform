variable "subnet_id" {
  description = "The subnet ID"
  type        = string
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