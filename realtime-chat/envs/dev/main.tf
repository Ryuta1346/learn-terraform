module "network" {
  source             = "../../modules/network"
  vpc_cidr_block     = var.vpc_cidr_block
  availability_zones = var.availability_zones
}

module "security_group" {
  source              = "../../modules/security_group"
  visitor_chat_vpc_id = module.network.visitor_chat_vpc_id
}

module "elb" {
  source                        = "../../modules/elb"
  visitor_chat_alb_sg_id        = module.security_group.visitor_chat_alb_sg_id
  for_each                      = toset(module.network.visitor_chat_public_subnets)
  visitor_chat_public_subnet_id = each.value
  visitor_chat_vpc_id           = module.network.visitor_chat_vpc_id
}

module "ecs" {
  source = "../../modules/ecs"
}