variable "net_nums" {
  description = "The number of subnets to create"
  type = object({
    public_1  = number
    private_1 = number
    private_2 = number
  })
  sensitive = false
  default = {
    public_1  = 0
    private_1 = 1
    private_2 = 2
  }
}

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
  source = "../../modules/subnet"
  subnet_vars = [
    {
      id                      = "${var.project_name}-${var.environment}-shared-public-1"
      vpc_id                  = module.vpc.vpc_id
      availability_zone       = var.availability_zones[0]
      cidr_block              = cidrsubnet(var.vpc_cidr_block, 4, var.net_nums.public_1)
      map_public_ip_on_launch = true
      is_private              = false
    }
  ]
  environment  = var.environment
  project_name = var.project_name
}


module "public_route_table" {
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
  source       = "../../modules/nat_gateway"
  subnet_id    = module.public_subnet.subnet_ids[0]
  environment  = var.environment
  project_name = var.project_name
}

## VPCエンドポイント用PrivateSubnet
module "private_vpc_endpoint_subnet" {
  source = "../../modules/subnet"
  subnet_vars = [
    {
      id                      = "${var.project_name}-${var.environment}-shared-private-1"
      vpc_id                  = module.vpc.vpc_id
      availability_zone       = var.availability_zones[0]
      cidr_block              = cidrsubnet(var.vpc_cidr_block, 4, var.net_nums.private_1)
      map_public_ip_on_launch = false
      is_private              = true
    }
  ]
  environment  = var.environment
  project_name = var.project_name
}

module "private_route_table" {
  source       = "../../modules/route_table"
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.private__vpc_endpoint_subnet.subnet_ids
  environment  = var.environment
  project_name = var.project_name
  routes = [
    {
      cidr_block = var.vpc_cidr_block,
      gateway_id = "local"
    }
  ]
}

module "private_chat_vpc_endpoint_sg" {
  source              = "../../modules/security_group"
  vpc_id              = module.vpc.vpc_id
  security_group_name = "shared-private-chat-vpc-endpoint-sg"
  description         = "Security group for the private subnet of shared chat vpc endpoint"
  sg_rules = {
    ingress_rules = [{
      from_port                = 80
      to_port                  = 80
      protocol                 = "tcp"
      source_security_group_id = module.private_ecs_chat_sg.sg_id
      },
      {
        from_port                = 443
        to_port                  = 443
        protocol                 = "tcp"
        source_security_group_id = module.private_ecs_chat_sg.sg_id
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
  name               = "shared-${var.project_name}-${var.environment}-chat-sqs"
  vpc_id             = module.vpc.vpc_id
  service_name       = "com.amazonaws.us-east-1.sqs"
  endpoint_type      = "Interface"
  security_group_ids = [module.private_chat_vpc_endpoint_sg.sg_id]
  subnet_ids         = [module.private_vpc_endpoint_subnet.subnet_ids[0]]
  environment        = var.environment
  project_name       = var.project_name
}

module "visitor_chat_queue_policy" {
  source    = "../../modules/iam_policy"
  sid       = "AllowVPCEndpointAccess"
  effect    = "Allow"
  actions   = ["sqs:ReceiveMessage", "sqs:DeleteMessage"]
  resources = [module.chat_queue.queue_arn]
  condition_vars = {
    test     = "ArnEquals"
    variable = "aws:SourceArn"
    values   = [module.sqs_chat_vpc_endpoint.vpc_endpoint_arn]
  }
}

resource "aws_sqs_queue_policy" "visitor_chat_queue_policy" {
  queue_url = var.chat_queue.id
  policy    = module.visitor_chat_queue_policy.policy_json
}

module "private_notify_vpc_endpoint_sg" {
  source              = "../../modules/security_group"
  vpc_id              = module.vpc.vpc_id
  security_group_name = "shared-private-notify-vpc-endpoint-sg"
  description         = "Security group for the private subnet of shared notify vpc endpoint"
  sg_rules = {
    ingress_rules = [{
      from_port                = 80
      to_port                  = 80
      protocol                 = "tcp"
      source_security_group_id = module.private_ecs_chat_sg.sg_id
      },
      {
        from_port                = 443
        to_port                  = 443
        protocol                 = "tcp"
        source_security_group_id = module.private_ecs_chat_sg.sg_id
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

## VPCエンドポイント用PrivateSubnet:外部通知用
module "sqs_notify_vpc_endpoint" {
  source             = "../../modules/vpc_endpoint"
  name               = "shared-${var.project_name}-${var.environment}-notify-sqs"
  vpc_id             = module.vpc.vpc_id
  service_name       = "com.amazonaws.us-east-1.sqs"
  endpoint_type      = "Interface"
  security_group_ids = [module.private_notify_vpc_endpoint_sg.sg_id]
  subnet_ids         = [module.private_vpc_endpoint_subnet.subnet_ids[0]]
  environment        = var.environment
  project_name       = var.project_name
}

module "notification_queue_policy" {
  source    = "../../modules/iam_policy"
  sid       = "AllowVPCEndpointAccess"
  effect    = "Allow"
  actions   = ["sqs:ReceiveMessage", "sqs:DeleteMessage"]
  resources = [module.notification_queue.queue_arn]
  condition_vars = {
    test     = "ArnEquals"
    variable = "aws:SourceArn"
    values   = [module.sqs_notify_vpc_endpoint.vpc_endpoint_arn]
  }
}

resource "aws_sqs_queue_policy" "notification_queue_policy" {
  queue_url = var.notification_queue.id
  policy    = module.notification_queue_policy.policy_json
}


## チャット永続化処理用ECS
module "private_ecs_chat_subnet" {
  source = "../../modules/subnet"
  subnet_vars = [
    {
      id                      = "${var.project_name}-${var.environment}-private-ecs-chat-1"
      vpc_id                  = module.vpc.vpc_id
      availability_zone       = var.availability_zones[0]
      cidr_block              = cidrsubnet(var.vpc_cidr_block, 4, var.net_nums.private_2)
      map_public_ip_on_launch = false
      is_private              = true
    }
  ]
  environment  = var.environment
  project_name = var.project_name
}

module "private_ecs_chat_sg" {
  source              = "../../modules/security_group"
  vpc_id              = module.vpc.vpc_id
  security_group_name = "private1"
  description         = "Security group for the Chat private subnet"
  sg_rules = {
    ingress_rules = [{
      from_port                = 80
      to_port                  = 80
      protocol                 = "tcp"
      source_security_group_id = module.private_chat_vpc_endpoint_sg.sg_id
      },
      {
        from_port                = 443
        to_port                  = 443
        protocol                 = "tcp"
        source_security_group_id = module.private_chat_vpc_endpoint_sg.sg_id
    }],
    egress_rules = [{
      from_port                = 0
      to_port                  = 0
      protocol                 = "-1"
      source_security_group_id = module.private_chat_vpc_endpoint_sg.sg_id
    }]
  }
  environment  = var.environment
  project_name = var.project_name
}

module "private_ecs_route_table" {
  source       = "../../modules/route_table"
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.private_ecs_chat_subnet.subnet_ids
  environment  = var.environment
  project_name = var.project_name
  routes = [
    {
      cidr_block = var.vpc_cidr_block,
      gateway_id = "local"
    }
  ]
}