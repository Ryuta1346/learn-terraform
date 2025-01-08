variable "policy_name" {
  description = "The name of the policy"
  type        = string
  sensitive   = false
}
variable "sid" {
  description = "The statement id"
  type        = string
  sensitive   = false
}

variable "effect" {
  description = "The effect of the policy"
  type        = string
  sensitive   = false
}

variable "actions" {
  description = "The actions for the policy"
  type        = list(string)
  sensitive   = false
}

variable "resources" {
  description = "The resources for the statement"
  type        = list(string)
  sensitive   = false
}

variable "condition_vars" {
  description = "The optional condition block variables"
  type = object({
    test     = optional(string)
    variable = optional(string)
    values   = optional(list(string))
  })
  default = null
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

variable "description" {
  description = "The description of the policy"
  type        = string
  sensitive   = false
}