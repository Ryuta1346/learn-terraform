module "network" {
  source             = "../../modules/network"
  vpc_cidr_block     = var.vpc_cidr_block
  availability_zones = var.availability_zones
  environment        = "dev"
}

module "visitor" {
  depends_on                  = [module.network]
  source                      = "../../services/visitor"
  visitor_chat_vpc_id         = module.network.visitor_chat_vpc_id
  visitor_chat_public_subnets = module.network.visitor_chat_public_subnets
  environment                 = "dev"
}