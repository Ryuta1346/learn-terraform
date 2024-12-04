module "security_group" {
  source              = "../../modules/security_group"
  visitor_chat_vpc_id = var.company_chat_vpc_id
  environment         = var.environment
}

module "elb" {
  source                        = "../../modules/elb"
  visitor_chat_alb_sg_id        = module.security_group.visitor_chat_alb_sg_id
  for_each                      = { for idx, subnet in var.company_chat_public_subnets : idx => subnet.id }
  visitor_chat_public_subnet_id = each.value
  visitor_chat_vpc_id           = var.company_chat_vpc_id
  environment                   = var.environment
}

module "ecs" {
  source      = "../../modules/ecs"
  environment = var.environment
}