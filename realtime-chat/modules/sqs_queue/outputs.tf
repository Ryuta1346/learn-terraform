output "queue_id" {
  description = "The ID of the SQS queue"
  value       = aws_sqs_queue.visitor_chat_queue.id
}