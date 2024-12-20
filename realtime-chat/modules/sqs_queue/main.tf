resource "aws_sqs_queue" "queue" {
  name = var.queue_name
  #   name                        = "${var.project_name}-${var.environment}-visitor-chat-queue.fifo"
  fifo_queue                  = var.queue_options.fifo_queue
  content_based_deduplication = var.queue_options.fifo_queue
  delay_seconds               = var.queue_options.delay_seconds             // default:0
  receive_wait_time_seconds   = var.queue_options.receive_wait_time_seconds // default:0

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}
