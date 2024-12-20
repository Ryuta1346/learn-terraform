variable "lambda_vars" {
  description = "The variables for the lambda function"
  type = object({
    function_name = string
    handler       = string
    runtime       = string
    filename      = string
    timeout       = number
    memory_size   = number
    environment   = map(string)
  })
  sensitive = false
  default = {
    function_name = "function"
    filename      = "index.zip"
    handler       = "index.handler"
    runtime       = "nodejs20.x"
    timeout       = 10
    memory_size   = 128
    environment   = {}
  }
}

variable "iam_role_arn" {
  description = "The ARN of the IAM role for the lambda function"
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
