# module "backup" {
#   source = "../../backup"
# }

# module "vpc" {
#   source         = "../../modules/vpc"
#   project_name   = var.project_name
#   environment    = var.environment
#   vpc_cidr_block = var.vpc_cidr_block
# }

# module "internet_gateway" {
#   source       = "../../modules/internet_gateway/"
#   vpc_id       = module.vpc.vpc_id
#   environment  = var.environment
#   project_name = var.project_name
# }

module "visitor_chat" {
  source = "../../services/visitor"
  # vpc_id              = module.vpc.vpc_id
  vpc_cidr_block = var.company_vpc_cidr_block
  # internet_gateway_id = module.internet_gateway.internet_gateway_id
  availability_zones = var.availability_zones
  environment        = var.environment
  project_name       = var.project_name
}

module "company_chat" {
  source = "../../services/company"
  # vpc_id              = module.vpc.vpc_id
  vpc_cidr_block = var.visitor_vpc_cidr_block
  # internet_gateway_id = module.internet_gateway.internet_gateway_id
  availability_zones = var.availability_zones
  environment        = var.environment
  project_name       = var.project_name
}

module "shared" {
  depends_on = [module.visitor_chat]
  source     = "../../services/shared"
  region     = "us-west-1"
  # vpc_id              = module.vpc.vpc_id
  vpc_cidr_block = var.shared_vpc_cidr_block
  # internet_gateway_id = module.internet_gateway.internet_gateway_id
  visitor_chat_sg_id = module.visitor_chat.visitor_ecs_sg_id
  availability_zones = var.availability_zones
  environment        = var.environment
  project_name       = var.project_name
}