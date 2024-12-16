module "visitor_chat" {
  source             = "../../services/visitor"
  vpc_cidr_block     = var.company_vpc_cidr_block
  availability_zones = var.availability_zones
  environment        = var.environment
  project_name       = var.project_name
}

module "company_chat" {
  source             = "../../services/company"
  vpc_cidr_block     = var.visitor_vpc_cidr_block
  availability_zones = var.availability_zones
  environment        = var.environment
  project_name       = var.project_name
}

module "shared" {
  depends_on         = [module.visitor_chat]
  source             = "../../services/shared"
  region             = "us-west-1"
  vpc_cidr_block     = var.shared_vpc_cidr_block
  availability_zones = var.availability_zones
  environment        = var.environment
  project_name       = var.project_name
  visitor_chat_queue = module.visitor_chat.visitor_chat_queue
  notification_queue = module.company_chat.notification_queue
}