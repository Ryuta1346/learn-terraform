variable "ecs_cluster_vars" {
  description = "values for ecs cluster"
  type = object({
    ecs_cluster_name     = string
    capacity_providers   = list(string)
    capacity_provider    = optional(string)
    default_base_count   = number
    default_weight_count = number
  })
}

variable "environment" {
  description = "The environment for the ECS service"
  type        = string
  sensitive   = false
}

variable "project_name" {
  description = "The name of the project"
  type        = string
  sensitive   = false
}