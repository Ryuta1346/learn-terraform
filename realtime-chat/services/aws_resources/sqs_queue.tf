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

## SQSからLambdaをトリガーする
module "sqs_lambda_role" {
  source = "../../modules/iam_role"
  assume_role_policy = {
    statement = [
      {
        action    = "sts:AssumeRole"
        principal = { service = "lambda.amazonaws.com" }
        effect    = "Allow"
      }
    ]
  }
  policy_arns  = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole", module.sqs_notify_lambda_policy.policy_arn]
  environment  = var.environment
  project_name = var.project_name
}

module "sqs_notify_lambda_policy" {
  source      = "../../modules/iam_policy"
  sid         = "AllowSQSAccessForLambda"
  effect      = "Allow"
  actions     = [
    "sqs:ReceiveMessage",
    "sqs:DeleteMessage",
    "sqs:GetQueueAttributes",
    "sqs:GetQueueUrl",
    "sqs:ChangeMessageVisibility"
  ]
  resources   = [module.chat_queue.queue_arn]
  project_name = var.project_name
  environment  = var.environment
  description  = "Policy for Lambda to access SQS"
}

module "sqs_notify_lambda" {
  source = "../../modules/lambda"
  lambda_vars = {
    function_name = "notify"
    handler       = "notify.handler"
    runtime       = "nodejs20.x"
    filename      = "notify.zip"
    memory_size   = 128
    timeout       = 10
    environment   = {}
  }
  environment  = var.environment
  project_name = var.project_name
  iam_role_arn = module.sqs_lambda_role.role_arn
}

resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = module.chat_queue.queue_arn
  function_name    = module.sqs_notify_lambda.function_arn
  batch_size       = 10 # 一度にLambdaが処理するメッセージ数
}