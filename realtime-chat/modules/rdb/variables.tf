variable "project_name" {
  description = "The name of the project"
  type        = string
  sensitive   = false
}

variable "environment" {
  description = "The environment for the company chat service"
  type        = string
  sensitive   = false
}

variable "db_subnet_group" {
  description = "The subnet group for the Aurora MySQL cluster"
  type = object({
    name        = string
    description = optional(string)
    subnet_ids  = list(string)
  })
}

variable "cluster_parameter_group" {
  description = "The parameter group for the Aurora MySQL cluster"
  type = object({
    name        = string
    family      = string
    description = optional(string)
    parameters = optional(list(object({
      name         = string
      value        = string
      apply_method = string
    })))
  })
}

variable "kms_parameters" {
  description = "The KMS key for the Aurora MySQL cluster"
  type = object({
    name                    = string
    description             = optional(string)
    enable_key_rotation     = optional(bool)
    rotation_period_in_days = optional(number)
    is_enabled              = optional(bool)
    deletion_window_in_days = optional(number)
    multi_region            = optional(bool)
  })
}

variable "ssm_master_password_path" {
  description = "The path to the SSM parameter for the master password"
  type        = string
  sensitive   = false
}

variable "rds_cluster_parameter" {
  description = "The parameter group for the RDS cluster"
  type = object({
    name                         = string
    cluster_identifier           = string
    deletion_protection          = bool
    engine                       = string
    engine_version               = string
    database_name                = string
    master_username              = string
    security_group_ids           = list(string)
    performance_insights_enabled = bool
    storage_type                 = string
    skip_final_snapshot          = bool
    storage_encrypted            = bool
    preferred_backup_window      = string
    preferred_maintenance_window = string
  })
}

variable "cluster_instance" {
  description = "The instance for the RDS cluster"
  type = object({
    count                        = number
    instance_class               = string
    availability_zones           = list(string)
    auto_minor_version_upgrade   = bool
    performance_insights_enabled = bool
  })

}