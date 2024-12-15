module "vpc" {
  source         = "../../modules/vpc"
  project_name   = var.project_name
  environment    = var.environment
  vpc_cidr_block = var.vpc_cidr_block
}

module "internet_gateway" {
  depends_on   = [module.vpc]
  source       = "../../modules/internet_gateway/"
  vpc_id       = module.vpc.vpc_id
  environment  = var.environment
  project_name = var.project_name
}

module "public_subnet" {
  depends_on = [module.internet_gateway]
  source     = "../../modules/subnet"
  subnet_vars = [
    {
      id                      = "${var.project_name}-${var.environment}-shared-public-1"
      vpc_id                  = module.vpc.vpc_id
      availability_zone       = var.availability_zones[0]
      cidr_block              = cidrsubnet(var.vpc_cidr_block, 4, 0)
      map_public_ip_on_launch = true
      is_private              = false
    }
  ]
  environment  = var.environment
  project_name = var.project_name
}


module "public_route_table" {
  depends_on   = [module.internet_gateway]
  source       = "../../modules/route_table"
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.public_subnet.subnet_ids
  environment  = var.environment
  project_name = var.project_name
  routes = [
    {
      cidr_block = "0.0.0.0/0",
      gateway_id = module.internet_gateway.internet_gateway_id
    }
  ]
}

module "public_nat_gateway" {
  depends_on   = [module.internet_gateway]
  source       = "../../modules/nat_gateway"
  subnet_id    = module.public_subnet.subnet_ids[0]
  environment  = var.environment
  project_name = var.project_name
}

## VPCエンドポイント用PrivateSubnet
module "private_subnet1" {
  source = "../../modules/subnet"
  subnet_vars = [
    {
      id                      = "${var.project_name}-${var.environment}-shared-private-1"
      vpc_id                  = module.vpc.vpc_id
      availability_zone       = var.availability_zones[0]
      cidr_block              = cidrsubnet(var.vpc_cidr_block, 4, 1)
      map_public_ip_on_launch = false
      is_private              = true
    }
  ]
  environment  = var.environment
  project_name = var.project_name
}

module "private_route_table" {
  depends_on   = [module.internet_gateway]
  source       = "../../modules/route_table"
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.private_subnet1.subnet_ids
  environment  = var.environment
  project_name = var.project_name
  routes = [
    {
      cidr_block = var.vpc_cidr_block,
      gateway_id = "local"
    }
  ]
}



module "private1_sg" {
  source              = "../../modules/security_group"
  vpc_id              = module.vpc.vpc_id
  security_group_name = "private1"
  description         = "Security group for the private subnet no1"
  sg_rules = {
    ingress_rules = [{
      from_port                = 80
      to_port                  = 80
      protocol                 = "tcp"
      source_security_group_id = var.visitor_chat_sg_id
      },
      {
        from_port                = 443
        to_port                  = 443
        protocol                 = "tcp"
        source_security_group_id = var.visitor_chat_sg_id
    }],
    egress_rules = [{
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }]
  }
  environment  = var.environment
  project_name = var.project_name
}

## VPCエンドポイント用PrivateSubnet:チャット永続処理用
module "sqs_chat_vpc_endpoint" {
  source             = "../../modules/vpc_endpoint"
  id                 = "${var.project_name}-${var.environment}-sqs-chat"
  vpc_id             = module.vpc.vpc_id
  service_name       = "com.amazonaws.${var.region}.sqs"
  endpoint_type      = "Interface"
  security_group_ids = [module.private1_sg.sg_id]
  subnet_ids         = [module.private_subnet1.subnet_ids[0]]
  environment        = var.environment
  project_name       = var.project_name
}

resource "aws_sqs_queue" "visitor_chat_queue" {
  name                        = "${var.project_name}-${var.environment}-visitor-chat-queue.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
  delay_seconds               = 0 // default:0
  receive_wait_time_seconds   = 0 // default:0

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_sqs_queue_policy" "visitor_chat_queue_policy" {
  queue_url = aws_sqs_queue.visitor_chat_queue.id
  policy    = data.aws_iam_policy_document.visitor_chat_queue_policy.json
}

data "aws_iam_policy_document" "visitor_chat_queue_policy" {
  statement {
    sid       = "AllowVPCEndpointAccess" // 管理用に設定
    effect    = "Allow"
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.visitor_chat_queue.arn]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [module.sqs_chat_vpc_endpoint.vpc_endpoint_arn]
    }
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

## VPCエンドポイント用PrivateSubnet:外部通知用
module "sqs_notify_vpc_endpoint" {
  source             = "../../modules/vpc_endpoint"
  id                 = "${var.project_name}-${var.environment}-sqs-notify"
  vpc_id             = module.vpc.vpc_id
  service_name       = "com.amazonaws.${var.region}.sqs"
  endpoint_type      = "Interface"
  security_group_ids = [module.private1_sg.sg_id]
  subnet_ids         = [module.private_subnet1.subnet_ids[0]]
  environment        = var.environment
  project_name       = var.project_name
}

resource "aws_sqs_queue" "notification_queue" {
  name                        = "${var.project_name}-${var.environment}-notification-queue.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
  delay_seconds               = 0 // default:0
  receive_wait_time_seconds   = 0 // default:0

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}


data "aws_iam_policy_document" "notification_queue_policy" {
  statement {
    sid       = "AllowVPCEndpointAccess" // 管理用に設定
    effect    = "Allow"
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.visitor_chat_queue.arn]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_vpc_endpoint.sqs_chat.arn]
    }
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_sqs_queue_policy" "notification_queue_policy" {
  queue_url = aws_sqs_queue.notification_queue.id
  policy    = data.aws_iam_policy_document.notification_queue_policy.json
}
