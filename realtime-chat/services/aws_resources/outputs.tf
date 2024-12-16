output "chat_queue" {
  description = "The ARN of the visitor chat queue"
  value       = module.chat_queue
}


output "notification_queue" {
  description = "The ARN of the visitor notification queue"
  value       = module.notification_queue
}