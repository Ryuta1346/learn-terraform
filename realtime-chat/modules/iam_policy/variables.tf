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

variable "principals_vars" {
  description = "The variables for the principals"
  type = object({
    type        = string
    identifiers = list(string)
  })
  sensitive = false
  default = {
    type        = "AWS"
    identifiers = ["*"]
  }
}