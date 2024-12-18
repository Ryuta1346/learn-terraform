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
  depends_on         = [module.visitor_chat]
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