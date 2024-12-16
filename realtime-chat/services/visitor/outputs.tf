output "visitor_ecs_sg_id" {
  value       = module.private_sg.sg_id
  description = "The ID of the security group"
}

output "visitor_chat_queue" {
  value       = module.visitor_chat_queue
  description = "The ARN of the visitor chat queue"
}

output "notification_queue" {
  value       = module.notification_queue
  description = "The ARN of the notification queue"
}