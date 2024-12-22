## ElastiCache用
module "private_elasticache_subnet" {
  source = "../../modules/subnet"
  subnet_vars = [
    {
      id                      = "${var.project_name}-${var.environment}-elasticache"
      vpc_id                  = module.vpc.vpc_id
      availability_zone       = var.availability_zones[0]
      cidr_block              = cidrsubnet(var.vpc_cidr_block, 4, local.subnets.elasticache1)
      map_public_ip_on_launch = false
      is_private              = true
    }
  ]
  environment  = var.environment
  project_name = var.project_name
}

module "private_elasticache_sg" {
  source              = "../../modules/security_group"
  vpc_id              = module.vpc.vpc_id
  security_group_name = "private-elasticache-sg"
  description         = "Security group for the private subnet of ElastiCache"
  sg_rules = {
    ingress_rules = [
      {
        from_port                = 80
        to_port                  = 80
        protocol                 = "tcp"
        source_security_group_id = module.chat_persistence_lambda_sg.sg_id
      },
      {
        from_port                = 443
        to_port                  = 443
        protocol                 = "tcp"
        source_security_group_id = module.chat_persistence_lambda_sg.sg_id
      },
    ],
    egress_rules = [
      {
        from_port                = 0
        to_port                  = 0
        protocol                 = "-1"
        source_security_group_id = module.chat_persistence_lambda_sg.sg_id
      }
    ]
  }
  environment  = var.environment
  project_name = var.project_name
}

module "private_elasticache_route_table" {
  source       = "../../modules/route_table"
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.private_elasticache_subnet.subnet_ids
  environment  = var.environment
  project_name = var.project_name
  routes = [
    {
      cidr_block = var.vpc_cidr_block,
      gateway_id = "local"
    }
  ]
}
