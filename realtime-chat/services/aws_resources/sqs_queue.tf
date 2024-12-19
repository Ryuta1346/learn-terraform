module "chat_queue" {
  source     = "../../modules/sqs_queue"
  queue_name = "${var.project_name}-${var.environment}-chat-queue.fifo"
  queue_options = {
    fifo_queue                = true
    delay_seconds             = 0
    receive_wait_time_seconds = 0
  }
  environment  = var.environment
  project_name = var.project_name
}

module "notification_queue" {
  source     = "../../modules/sqs_queue"
  queue_name = "${var.project_name}-${var.environment}-notification-queue.fifo"
  queue_options = {
    fifo_queue                = true
    delay_seconds             = 0
    receive_wait_time_seconds = 0
  }
  environment  = var.environment
  project_name = var.project_name
}