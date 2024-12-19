variable "queue_name" {
  description = "The name of the queue"
  type        = string
  sensitive   = false
}

variable "queue_options" {
  description = "The options for the queue"
  type = object({
    fifo_queue                = bool
    delay_seconds             = number
    receive_wait_time_seconds = number
  })
  sensitive = false
  default = {
    fifo_queue                = false
    delay_seconds             = 0
    receive_wait_time_seconds = 0
  }

}

variable "environment" {
  description = "The environment for the service"
  type        = string
  sensitive   = false
}

variable "project_name" {
  description = "The name of the project"
  type        = string
  sensitive   = false
}