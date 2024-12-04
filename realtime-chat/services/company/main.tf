module "security_group" {
  source      = "../../modules/security_group"
  vpc_id      = var.vpc_id
  environment = var.environment
}

module "elb" {
  source           = "../../modules/elb"
  alb_sg_id        = module.security_group.alb_sg_id
  for_each         = { for idx, subnet in var.public_subnets : idx => subnet.id }
  public_subnet_id = each.value
  vpc_id           = var.vpc_id
  environment      = var.environment
}

module "ecs" {
  source      = "../../modules/ecs"
  environment = var.environment
}