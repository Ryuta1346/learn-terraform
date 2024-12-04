variable "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  type        = string
  sensitive   = false
}

variable "capacity_providers" {
  description = "The capacity providers for the ECS cluster"
  type        = list(string)
  sensitive   = false
  default     = ["FARGATE", "FARGATE_SPOT"]
}

variable "default_base_count" {
  description = "The base count for the ECS service"
  type        = number
  sensitive   = false
  default     = 1
}

variable "default_weight_count" {
  description = "The weight count for the ECS service"
  type        = number
  sensitive   = false
  default     = 1

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