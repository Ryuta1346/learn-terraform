module "visitor_chat_network" {
  source             = "../../modules/network"
  vpc_cidr_block     = var.visitor_vpc_cidr_block
  availability_zones = var.availability_zones
  environment        = "dev"
}

module "visitor_chat_service" {
  depends_on                  = [module.network]
  source                      = "../../services/visitor"
  visitor_chat_vpc_id         = module.network.visitor_chat_vpc_id
  visitor_chat_public_subnets = module.network.visitor_chat_public_subnets
  environment                 = "dev"
}

module "company_chat_network" {
  source             = "../../modules/network"
  vpc_cidr_block     = var.company_vpc_cidr_block
  availability_zones = var.availability_zones
  environment        = "dev"
}