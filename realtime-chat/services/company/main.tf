variable "subnet_cidrs" {
  description = "The CIDR blocks for the subnets"
  type = list(object({
    public_1  = string
    public_2  = string
    private_1 = string
  }))
  sensitive = false
  default = [{
    public_1  = cidrsubnet(var.vpc_cidr_block, 24, 8)
    public_2  = cidrsubnet(var.vpc_cidr_block, 24, 9)
    private_1 = cidrsubnet(var.vpc_cidr_block, 24, 10)
  }]
}

module "public_subnet" {
  source = "../../modules/subnet"
  subnet_vars = [
    {
      id                      = "${var.project_name}-${var.environment}-company-public-1"
      vpc_id                  = var.vpc_id
      availability_zone       = var.availability_zones[0]
      cidr_block              = cidrsubnet(var.vpc_cidr_block, 4, 0)
      map_public_ip_on_launch = true
      is_private              = false
    },
    {
      id                      = "${var.project_name}-${var.environment}-company-public-2"
      vpc_id                  = var.vpc_id
      availability_zone       = var.availability_zones[1]
      cidr_block              = cidrsubnet(var.vpc_cidr_block, 4, 1)
      map_public_ip_on_launch = true
      is_private              = false
    }
  ]
  environment  = var.environment
  project_name = var.project_name
}

module "public_route_table" {
  source       = "../../modules/route_table"
  vpc_id       = var.vpc_id
  subnet_ids   = module.public_subnet.subnet_ids
  environment  = var.environment
  project_name = var.project_name
  routes = [
    {
      cidr_block = "0.0.0.0/0",
      gateway_id = var.internet_gateway_id
    }
  ]
}

module "public_alb_sg" {
  source              = "../../modules/security_group"
  security_group_name = "company-chat-public"
  description         = "The security group for the public ALB"
  vpc_id              = var.vpc_id
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

module "private_subnet" {
  source = "../../modules/subnet"
  subnet_vars = [
    {
      id                      = "${var.project_name}-${var.environment}-company-private-1"
      vpc_id                  = var.vpc_id
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
  source       = "../../modules/route_table"
  subnet_ids   = module.private_subnet.subnet_ids
  vpc_id       = var.vpc_id
  environment  = var.environment
  project_name = var.project_name
  routes = [
    {
      cidr_block = var.vpc_cidr_block,
      gateway_id = "local"
    }
  ]
}

module "private_sg" {
  source              = "../../modules/security_group"
  security_group_name = "company-chat-private"
  description         = "Security group for the private subnet"
  vpc_id              = var.vpc_id
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
