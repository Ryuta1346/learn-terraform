module "aws_resources" {
  source       = "../../services/aws_resources"
  environment  = var.environment
  project_name = var.project_name
}
module "visitor_chat" {
  depends_on     = [module.aws_resources]
  source         = "../../services/visitor"
  vpc_cidr_block = var.company_vpc_cidr_block
  chat_queue = {
    id  = module.aws_resources.chat_queue.id
    arn = module.aws_resources.chat_queue.arn
  }
  notification_queue = {
    id  = module.aws_resources.notification_queue.id
    arn = module.aws_resources.notification_queue.arn
  }
  availability_zones = var.availability_zones
  environment        = var.environment
  project_name       = var.project_name
}

module "company_chat" {
  depends_on         = [module.aws_resources]
  source             = "../../services/company"
  vpc_cidr_block     = var.visitor_vpc_cidr_block
  availability_zones = var.availability_zones
  chat_queue = {
    id  = module.aws_resources.chat_queue.id
    arn = module.aws_resources.chat_queue.arn
  }
  notification_queue = {
    id  = module.aws_resources.notification_queue.id
    arn = module.aws_resources.notification_queue.arn
  }
  environment  = var.environment
  project_name = var.project_name
}

module "shared" {
  depends_on         = [module.visitor_chat, module.company_chat]
  source             = "../../services/shared"
  region             = var.region
  vpc_cidr_block     = var.shared_vpc_cidr_block
  availability_zones = var.availability_zones
  environment        = var.environment
  project_name       = var.project_name
  chat_queue = {
    id  = module.aws_resources.chat_queue.id
    arn = module.aws_resources.chat_queue.arn
  }
  notification_queue = {
    id  = module.aws_resources.notification_queue.id
    arn = module.aws_resources.notification_queue.arn
  }
  visitor_vars = {
    vpc_id             = module.visitor_chat.vpc_id
    vpc_cider_block    = module.visitor_chat.vpc_cidr_block
    ecs_route_table_id = module.visitor_chat.ecs_route_table_id
    ecs_chat_sg_id     = module.visitor_chat.ecs_chat_sg_id
  }

  company_vars = {
    vpc_id             = module.company_chat.vpc_id
    vpc_cider_block    = module.company_chat.vpc_cidr_block
    ecs_route_table_id = module.company_chat.ecs_route_table_id
    ecs_chat_sg_id     = module.company_chat.ecs_chat_sg_id
  }
}

# module "shared_company_deps" {
#   depends_on                            = [module.shared]
#   source                                = "../../services/shared-company-deps"
#   project_name                          = var.project_name
#   environment                           = var.environment
#   shared_chat_private_aurora_sg_id      = module.shared.private_aurora_sg_id
#   shared_chat_private_elasticache_sg_id = module.shared.private_elasticache_sg_id
#   shared_chat_vpc_id                    = module.shared.vpc_id
#   company_chat_vpc_id                   = module.company_chat.vpc_id
#   company_ecs_route_table_id            = module.company_chat.ecs_route_table_id
#   company_ecs_chat_sg_id                = module.company_chat.ecs_chat_sg_id
#   company_vpc_cider_block               = module.company_chat.vpc_cidr_block
# }

# module "shared_visitor_deps" {
#   depends_on                            = [module.shared]
#   source                                = "../../services/shared-visitor-deps"
#   project_name                          = var.project_name
#   environment                           = var.environment
#   shared_chat_private_aurora_sg_id      = module.shared.private_aurora_sg_id
#   shared_chat_private_elasticache_sg_id = module.shared.private_elasticache_sg_id
#   shared_chat_vpc_id                    = module.shared.vpc_id
#   visitor_chat_vpc_id                   = module.visitor_chat.vpc_id
#   visitor_ecs_route_table_id            = module.visitor_chat.ecs_route_table_id
#   visitor_ecs_chat_sg_id                = module.visitor_chat.ecs_chat_sg_id
#   visitor_vpc_cider_block               = module.visitor_chat.vpc_cidr_block
# }