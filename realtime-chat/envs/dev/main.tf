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
  region             = "us-west-1"
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
}