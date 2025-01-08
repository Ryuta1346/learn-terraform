## VPCエンドポイント用PrivateSubnet
module "chat_persistence_lambda_subnet" {
  source = "../../modules/subnet"
  subnet_vars = [
    {
      id                      = "${var.project_name}-${var.environment}-shared-chat-persistence-lambda-private1"
      vpc_id                  = module.vpc.vpc_id
      availability_zone       = var.availability_zones[0]
      cidr_block              = cidrsubnet(var.vpc_cidr_block, 4, local.subnets.lambda1)
      map_public_ip_on_launch = false
      is_private              = true
    }
  ]
  environment  = var.environment
  project_name = var.project_name
}

module "chat_persistence_route_table" {
  source       = "../../modules/route_table"
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.chat_persistence_lambda_subnet.subnet_ids
  environment  = var.environment
  project_name = var.project_name
  routes = [
    {
      cidr_block = var.vpc_cidr_block,
      gateway_id = "local"
    }
  ]
}

module "chat_persistence_lambda_sg" {
  source              = "../../modules/security_group"
  vpc_id              = module.vpc.vpc_id
  security_group_name = "shared-private-chat-persistence-lambda-sg"
  description         = "Security group for the private subnet of shared chat persistence lambda"
  sg_rules = {
    # 内部的にAWS LambdaからSQSをポーリングするためSQSからのIngressルールは不要
    ingress_rules = [],
    egress_rules = [{
      from_port                = 3306
      to_port                  = 3306
      protocol                 = "tcp"
      source_security_group_id = module.private_aurora_sg.sg_id
    }]
  }
  environment  = var.environment
  project_name = var.project_name
}

# SQSからLambdaをトリガーする
module "sqs_chat_lambda_policy" {
  policy_name = "sqs-chat-lambda-policy"
  source      = "../../modules/iam_policy"
  sid         = "AllowVPCEndpointAccess"
  effect      = "Allow"
  actions = [
    "sqs:ReceiveMessage",
    "sqs:DeleteMessage",
    "sqs:SendMessage",
    "sqs:GetQueueAttributes"
  ]
  resources    = [var.chat_queue.arn]
  project_name = var.project_name
  environment  = var.environment
  description  = "Policy for Lambda to access SQS"
}

module "sqs_chat_lambda_role" {
  role_name = "sqs-chat-lambda-role"
  source    = "../../modules/iam_role"
  assume_role_policy = {
    statement = [
      {
        action    = "sts:AssumeRole"
        principal = { service = "lambda.amazonaws.com" }
        effect    = "Allow"
      }
    ]
  }
  policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    module.sqs_chat_lambda_policy.policy_arn
  ]
  environment  = var.environment
  project_name = var.project_name
}

module "chat_persistence_lambda" {
  source = "../../modules/lambda"
  lambda_vars = {
    function_name = "chat-persistence"
    handler       = "notify.handler"
    runtime       = "nodejs20.x"
    filename      = "chat-persistence.zip"
    memory_size   = 128
    timeout       = 10
    environment   = {}
  }
  environment  = var.environment
  project_name = var.project_name
  iam_role_arn = module.sqs_chat_lambda_role.role_arn
}

resource "aws_lambda_event_source_mapping" "sqs_trigger_chat" {
  event_source_arn = var.chat_queue.arn
  function_name    = module.chat_persistence_lambda.function_arn
  batch_size       = 10 # 一度にLambdaが処理するメッセージ数
}