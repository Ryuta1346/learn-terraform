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
  depends_on              = [module.internet_gateway]
  source                  = "../../modules/subnet"
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 4, 0)
  project_name            = var.project_name
  vpc_id                  = module.vpc.vpc_id
  environment             = var.environment
  availability_zones      = var.availability_zones
  map_public_ip_on_launch = true
  private                 = false
  subnet_count            = var.public_subnet_count
}

module "public_route_table" {
  depends_on   = [module.internet_gateway]
  source       = "../../modules/route_table"
  vpc_id       = module.vpc.vpc_id
  environment  = var.environment
  project_name = var.project_name
  routes = [
    {
      cidr_block = "0.0.0.0/0",
      gateway_id = module.internet_gateway.internet_gateway_id
    }
  ]
}

resource "aws_route_table_association" "public_association" {
  depends_on     = [module.public_subnet, module.public_route_table]
  for_each       = { for idx, id in module.public_subnet.subnet_ids : idx => id }
  subnet_id      = each.value
  route_table_id = module.public_route_table.route_table_id
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name        = "${var.project_name}-${var.environment}-nat-eip"
    project     = var.project_name
    environment = var.environment
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  depends_on    = [module.internet_gateway, aws_eip.nat_eip]
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = module.public_subnet.subnet_ids[0]
}

module "private_subnet" {
  source                  = "../../modules/subnet"
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 4, 2)
  project_name            = var.project_name
  vpc_id                  = module.vpc.vpc_id
  environment             = var.environment
  availability_zones      = var.availability_zones
  map_public_ip_on_launch = false
  private                 = true
  subnet_count            = var.private_subnet_count
}

module "private_route_table" {
  depends_on   = [module.internet_gateway]
  source       = "../../modules/route_table"
  vpc_id       = module.vpc.vpc_id
  environment  = var.environment
  project_name = var.project_name
  routes = [
    {
      cidr_block = var.vpc_cidr_block,
      gateway_id = "local"
    }
  ]
}

resource "aws_route_table_association" "private_association" {
  depends_on     = [module.private_subnet, module.private_route_table]
  for_each       = { for idx, id in module.private_subnet.subnet_ids : idx => id }
  subnet_id      = each.value
  route_table_id = module.private_route_table.route_table_id
}



resource "aws_security_group" "private1" {
  name        = "shared-private1-sg"
  description = "Security group for shared-private1-sg"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name        = "${var.project_name}-${var.environment}-private1-sg"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_vpc_security_group_egress_rule" "private_all_traffic" {
  security_group_id = aws_security_group.private1.id
  from_port         = -1
  to_port           = -1
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow all outbound traffic"
}

resource "aws_vpc_security_group_ingress_rule" "visitor_chat" {
  security_group_id            = aws_security_group.private1.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
  referenced_security_group_id = var.visitor_chat_sg_id

  tags = {
    Name        = "${var.project_name}-${var.environment}-${aws_security_group.private1.name}-ingress"
    Environment = var.environment
    Project     = var.project_name
  }
}

## チャット永続処理用
resource "aws_vpc_endpoint" "sqs_chat" {
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${var.region}.sqs"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.private1.id]
  subnet_ids          = [module.private_subnet.subnet_ids[0]]
  private_dns_enabled = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-sqs_chat-vpc-endpoint"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_sqs_queue" "visitor_chat_queue" {
  name                        = "${var.project_name}-${var.environment}-visitor-chat-queue.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
  delay_seconds               = 0 // default:0
  receive_wait_time_seconds   = 0 // default:0

  tags = {
    Name        = "${var.project_name}-${var.environment}-visitor-chat-queue.fifo"
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
      values   = [aws_vpc_endpoint.sqs_chat.arn]
    }
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

// 外部通知用
resource "aws_vpc_endpoint" "sqs_notification" {
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${var.region}.sqs"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.private1.id]
  subnet_ids          = [module.private_subnet.subnet_ids[0]]
  private_dns_enabled = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-sqs_notification-vpc-endpoint"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_sqs_queue" "notification_queue" {
  name                        = "${var.project_name}-${var.environment}-notification-queue.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
  delay_seconds               = 0 // default:0
  receive_wait_time_seconds   = 0 // default:0

  tags = {
    Name        = "${var.project_name}-${var.environment}-notification-queue"
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
