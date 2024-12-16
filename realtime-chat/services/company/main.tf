variable "net_nums" {
  description = "The number of subnets to create"
  type = object({
    public_1  = number
    public_2  = number
    private_1 = number
    private_2 = number
  })
  sensitive = false
  default = {
    public_1  = 0
    public_2  = 1
    private_1 = 2
    private_2 = 3
  }
}

module "vpc" {
  source         = "../../modules/vpc"
  project_name   = var.project_name
  environment    = var.environment
  vpc_cidr_block = var.vpc_cidr_block
  vpc_name       = "company-${var.project_name}-${var.environment}"
}

module "internet_gateway" {
  depends_on   = [module.vpc]
  source       = "../../modules/internet_gateway/"
  vpc_id       = module.vpc.vpc_id
  environment  = var.environment
  project_name = var.project_name
  gateway_name = "company-${var.project_name}-${var.environment}-igw"
}

module "public_subnet" {
  source = "../../modules/subnet"
  subnet_vars = [
    {
      id                      = "${var.project_name}-${var.environment}-company-public-1"
      vpc_id                  = module.vpc.vpc_id
      availability_zone       = var.availability_zones[0]
      cidr_block              = cidrsubnet(var.vpc_cidr_block, 4, var.net_nums.public_1)
      map_public_ip_on_launch = true
      is_private              = false
    },
    {
      id                      = "${var.project_name}-${var.environment}-company-public-2"
      vpc_id                  = module.vpc.vpc_id
      availability_zone       = var.availability_zones[1]
      cidr_block              = cidrsubnet(var.vpc_cidr_block, 4, var.net_nums.public_2)
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

module "public_alb_sg" {
  source              = "../../modules/security_group"
  security_group_name = "company-chat-public"
  description         = "The security group for the public ALB"
  vpc_id              = module.vpc.vpc_id
  sg_rules = {
    ingress_rules = [
      {
        from_port   = 80
        to_port     = 80
        protocol    = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow HTTP traffic from anywhere"
      },
      {
        from_port   = 443
        to_port     = 443
        protocol    = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow HTTPS traffic from anywhere"
      }
    ],
    egress_rules = [
      {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow all outbound traffic"
      }
    ]
  }
  environment  = var.environment
  project_name = var.project_name
}

module "elb" {
  depends_on = [module.public_subnet]
  source     = "../../modules/elb"
  elb_vars = [
    {
      elb_name                   = "company-chat"
      internal                   = false
      load_balancer_type         = "application"
      security_group_ids         = [module.public_alb_sg.sg_id]
      subnet_ids                 = module.public_subnet.subnet_ids
      enable_deletion_protection = false
      access_logs_enabled        = false
    }
  ]
  environment  = var.environment
  project_name = var.project_name
}

module "private_subnet_ecs" {
  source = "../../modules/subnet"
  subnet_vars = [
    {
      id                      = "${var.project_name}-${var.environment}-company-private-1"
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
  subnet_ids   = module.private_subnet_ecs.subnet_ids
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

module "private_ecs_sg" {
  source              = "../../modules/security_group"
  security_group_name = "company-chat-private"
  description         = "Security group for the private subnet"
  vpc_id              = module.vpc.vpc_id
  sg_rules = {
    ingress_rules = [{
      from_port                = 80
      to_port                  = 80
      protocol                 = "tcp"
      source_security_group_id = module.public_alb_sg.sg_id
      },
      {
        from_port                = 443
        to_port                  = 443
        protocol                 = "tcp"
        source_security_group_id = module.public_alb_sg.sg_id
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

module "ecs" {
  source = "../../modules/ecs"
  ecs_cluster_vars = {
    ecs_cluster_name     = "company-chat"
    capacity_providers   = ["FARGATE"]
    default_base_count   = 1
    default_weight_count = 1
  }
  environment  = var.environment
  project_name = var.project_name
}

module "private_subnet_for_vpc_endpoint" {
  source = "../../modules/subnet"
  subnet_vars = [
    {
      id                      = "${var.project_name}-${var.environment}-company-private-2"
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

module "private_vpc_endpoint_route_table" {
  source       = "../../modules/route_table"
  subnet_ids   = module.private_subnet_for_vpc_endpoint.subnet_ids
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

module "private_vpc_endpoint_sg" {
  source              = "../../modules/security_group"
  security_group_name = "company-chat-vpc-endpoint-private"
  description         = "Security group for the private subnet"
  vpc_id              = module.vpc.vpc_id
  sg_rules = {
    ingress_rules = [{
      from_port                = 80
      to_port                  = 80
      protocol                 = "tcp"
      source_security_group_id = module.private_ecs_sg.sg_id
      },
      {
        from_port                = 443
        to_port                  = 443
        protocol                 = "tcp"
        source_security_group_id = module.private_ecs_sg.sg_id
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

## VPCエンドポイント用PrivateSubnet:チャット永続化用
module "sqs_chat_vpc_endpoint" {
  source             = "../../modules/vpc_endpoint"
  name               = "company-${var.project_name}-${var.environment}-sqs-chat"
  vpc_id             = module.vpc.vpc_id
  service_name       = "com.amazonaws.us-east-1.sqs"
  endpoint_type      = "Interface"
  security_group_ids = [module.private_vpc_endpoint_sg.sg_id]
  subnet_ids         = [module.private_subnet_for_vpc_endpoint.subnet_ids[0]]
  environment        = var.environment
  project_name       = var.project_name
}

module "visitor_chat_queue_policy" {
  source    = "../../modules/iam_policy"
  sid       = "AllowVPCEndpointAccess"
  effect    = "Allow"
  actions   = ["sqs:SendMessage"]
  resources = [var.chat_queue.arn]
  condition_vars = {
    test     = "StringEquals"
    variable = "aws:SourceVpc"
    values   = [module.vpc.vpc_id]
  }
}

resource "aws_sqs_queue_policy" "visitor_chat_queue_policy" {
  queue_url = var.chat_queue.id
  policy    = module.visitor_chat_queue_policy.policy_json
}
