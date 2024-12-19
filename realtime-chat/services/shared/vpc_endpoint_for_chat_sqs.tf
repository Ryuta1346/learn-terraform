## VPCエンドポイント用PrivateSubnet
module "private_vpc_endpoint_subnet" {
  source = "../../modules/subnet"
  subnet_vars = [
    {
      id                      = "${var.project_name}-${var.environment}-shared-private-1"
      vpc_id                  = module.vpc.vpc_id
      availability_zone       = var.availability_zones[0]
      cidr_block              = cidrsubnet(var.vpc_cidr_block, 4, local.net_nums.private_1)
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
  subnet_ids   = module.private_vpc_endpoint_subnet.subnet_ids
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
module "sqs_vpc_endpoint" {
  source             = "../../modules/vpc_endpoint"
  name               = "shared-${var.project_name}-${var.environment}-sqs"
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
  resources = [var.chat_queue.arn]
  condition_vars = {
    test     = "StringEquals"
    variable = "aws:SourceVpc"
    values   = [module.vpc.vpc_id]
  }
  project_name = var.project_name
  environment  = var.environment
  description  = "Policy for VPC Endpoint to access SQS"
}

resource "aws_sqs_queue_policy" "visitor_chat_queue_policy" {
  queue_url = var.chat_queue.id
  policy    = module.visitor_chat_queue_policy.policy_json
}