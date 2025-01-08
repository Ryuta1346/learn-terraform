variable "role_name" {
  description = "The name of the role"
  type        = string
  sensitive   = false
}

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

variable "assume_role_policy" {
  description = "The assume role policy"
  type = object({
    statement = list(object({
      action = string
      principal = object({
        service = string
      })
      effect = string
    }))
  })
  sensitive = false
}

variable "policy_arns" {
  description = "The ARNs of the policies to attach to the role"
  type        = list(string)
  sensitive   = false
}