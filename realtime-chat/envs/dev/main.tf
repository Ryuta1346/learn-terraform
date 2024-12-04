module "visitor_chat_network" {
  source             = "../../modules/network"
  vpc_cidr_block     = var.visitor_vpc_cidr_block
  availability_zones = var.availability_zones
  environment        = "dev"
}

module "visitor_chat_service" {
  depends_on                  = [module.visitor_chat_network]
  source                      = "../../services/visitor"
  visitor_chat_vpc_id         = module.visitor_chat_network.vpc_id
  visitor_chat_public_subnets = module.visitor_chat_network.public_subnets
  environment                 = "dev"
}

module "company_chat_network" {
  source             = "../../modules/network"
  vpc_cidr_block     = var.company_vpc_cidr_block
  availability_zones = var.availability_zones
  environment        = "dev"
}

module "company_chat_service" {
  depends_on                  = [module.company_chat_network]
  source                      = "../../services/visitor"
  visitor_chat_vpc_id         = module.company_chat_network.vpc_id
  visitor_chat_public_subnets = module.company_chat_network.public_subnets
  environment                 = "dev"
}