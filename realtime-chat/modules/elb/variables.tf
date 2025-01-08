variable "elb_vars" {
  description = "values for elb"
  type = list(object({
    elb_name                   = string
    internal                   = bool
    load_balancer_type         = string
    security_group_ids         = list(string)
    subnet_ids                 = list(string)
    enable_deletion_protection = bool
    access_logs_enabled        = bool
  }))
}

variable "environment" {
  description = "environment"
  type        = string
}

variable "project_name" {
  description = "project name"
  type        = string
}