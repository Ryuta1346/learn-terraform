variable "vpc_id" {
  description = "The ID of the Chat VPC"
  type        = string
}

variable "security_group_name" {
  description = "The name of the security group"
  type        = string
}

variable "description" {
  description = "The description of the security group"
  type        = string
}

variable "sg_rules" {
  description = "The security group variables"
  type = object({
    ingress_rules = list(object({
      from_port                = number
      to_port                  = number
      protocol                 = string
      cidr_blocks              = optional(list(string), [])
      description              = optional(string)
      source_security_group_id = optional(string)
    }))
    egress_rules = list(object({
      from_port                = number
      to_port                  = number
      protocol                 = string
      cidr_blocks              = optional(list(string), [])
      description              = optional(string)
      source_security_group_id = optional(string)
    }))
  })
  validation {
    // ingress_rulesではsource_security_group_idを指定しない場合はcidr_blocksを指定する必要がある
    condition = alltrue([
      for rule in var.sg_rules.ingress_rules : rule.source_security_group_id != null || rule.cidr_blocks != []
    ])
    error_message = "Either cidr_blocks or source_security_group_id must be specified for ingress_rules"
  }
  validation {
    // egress_rulesではsource_security_group_idを指定しない場合はcidr_blocksを指定する必要がある
    condition = alltrue([
      for rule in var.sg_rules.egress_rules : rule.source_security_group_id != null || rule.cidr_blocks != []
    ])
    error_message = "Either cidr_blocks or source_security_group_id must be specified for egress_rules"
  }
}

variable "environment" {
  description = "The environment for the security group"
  type        = string
}

variable "project_name" {
  description = "The name of the project"
  type        = string
}