output "chat_queue" {
  description = "The ARN of the visitor chat queue"
  value = {
    id  = var.visitor_chat_queue.id
    arn = var.visitor_chat_queue.arn
  }
}


output "visitor_notification_queue" {
  description = "The ARN of the visitor notification queue"
  value = {
    id  = var.visitor_notification_queue.id
    arn = var.visitor_notification_queue.arn
  }
}