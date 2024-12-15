output "queue_id" {
  description = "The ID of the SQS queue"
  value       = aws_sqs_queue.visitor_chat_queue.id
}

output "queue_arn" {
  description = "The ARN of the SQS queue"
  value       = aws_sqs_queue.visitor_chat_queue.arn
}