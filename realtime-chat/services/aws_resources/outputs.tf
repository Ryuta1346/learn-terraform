output "chat_queue" {
  description = "The ARN of the visitor chat queue"
  value = {
    id  = module.chat_queue.id
    arn = module.chat_queue.arn
  }
}


output "notification_queue" {
  description = "The ARN of the visitor notification queue"
  value = {
    id  = module.notification_queue.id
    arn = module.notification_queue.arn
  }
}