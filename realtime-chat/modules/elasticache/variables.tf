variable "project_name" {
  description = "The name of the project"
  type        = string
  sensitive   = false
}

variable "environment" {
  description = "The environment to deploy the resources"
  type        = string
  sensitive   = false
}

variable "elasticache_sg_id" {
  description = "The ID of the security group for ElastiCache"
  type        = string
  sensitive   = true
}

variable "elasticache_subnet_ids" {
  description = "The IDs of the subnets for ElastiCache"
  type        = list(string)
  sensitive   = true
}

variable "engine" {
  description = "The engine of the ElastiCache cluster"
  type        = string
  sensitive   = false
}

variable "major_engine_version" {
  description = "The major version of the engine of the ElastiCache cluster"
  type        = string
  sensitive   = false
}

variable "cache_storage_max_gb" {
  description = "The maximum data storage capacity of the ElastiCache cluster"
  type        = number
  sensitive   = false
}

variable "ecpu_per_second_max" {
  description = "The maximum eCPU per second of the ElastiCache cluster"
  type        = number
  sensitive   = false

}

variable "daily_snapshot_time" {
  description = "The time of day when ElastiCache takes a daily snapshot"
  type        = string
  sensitive   = false
}

variable "elasticache_user_group_id" {
  description = "The ID of the user group for ElastiCache"
  type        = string
  sensitive   = true
}