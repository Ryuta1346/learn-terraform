## ElastiCache用
module "private_elasticache_subnet" {
  source = "../../modules/subnet"
  subnet_vars = [
    {
      id                      = "${var.project_name}-${var.environment}-elasticache1"
      vpc_id                  = module.vpc.vpc_id
      availability_zone       = var.availability_zones[0]
      cidr_block              = cidrsubnet(var.vpc_cidr_block, 4, local.subnets.elasticache1)
      map_public_ip_on_launch = false
      is_private              = true
    },
    {
      id                      = "${var.project_name}-${var.environment}-elasticache2"
      vpc_id                  = module.vpc.vpc_id
      availability_zone       = var.availability_zones[1]
      cidr_block              = cidrsubnet(var.vpc_cidr_block, 4, local.subnets.elasticache2)
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

# data "aws_ssm_parameter" "elasticache_user_group_id" {
#   count = var.cluster.elasticache_user_group_path != "" ? 1 : 0
#   name  = var.cluster.elasticache_user_group_path
# }

module "shared_elasticache" {
  source                    = "../../modules/elasticache"
  project_name              = var.project_name
  environment               = var.environment
  elasticache_sg_id         = module.private_elasticache_sg.sg_id
  elasticache_subnet_ids    = module.private_elasticache_subnet.subnet_ids
  engine                    = var.cluster.engine
  cache_storage_max_gb      = var.cluster.cache_storage_max_gb
  ecpu_per_second_max       = var.cluster.ecpu_per_second_max
  daily_snapshot_time       = var.cluster.daily_snapshot_time
  major_engine_version      = var.cluster.major_engine_version
  elasticache_user_group_id = null
}
