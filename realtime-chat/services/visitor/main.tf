module "vpc" {
  source         = "../../modules/vpc"
  project_name   = var.project_name
  environment    = var.environment
  vpc_cidr_block = var.vpc_cidr_block
}

module "public_subnet" {
  source                  = "../../modules/subnet"
  cidr_block              = cidrsubnet(module.vpc.cidr_block, 4, 1)
  project_name            = var.project_name
  vpc_id                  = module.vpc.vpc_id
  environment             = var.environment
  availability_zones      = var.availability_zones
  map_public_ip_on_launch = true
  subnet_count            = var.public_subnet_count
}

module "internet_gateway" {
  source       = "../../modules/internet_gateway/"
  vpc_id       = module.vpc.vpc_id
  environment  = var.environment
  project_name = var.project_name
}

module "route_table" {
  source                 = "../../modules/route_table"
  subnet_id              = module.public_subnet.subnet_id
  internet_gateway_id    = module.internet_gateway.internet_gateway_id
  route_table_cidr_block = "0.0.0.0/0"
  vpc_id                 = module.vpc.vpc_id
  environment            = var.environment
  project_name           = var.project_name
}

module "public_alb_sg" {
  source              = "../../modules/security_group"
  security_group_name = "visitor-chat-public"
  vpc_id              = module.vpc.vpc_id
  environment         = var.environment
  project_name        = var.project_name
}


module "elb" {
  source       = "../../modules/elb"
  elb_name     = "visitor-chat-public"
  vpc_id       = module.vpc.vpc_id
  alb_sg_id    = module.public_alb_sg.alb_sg_id
  subnet_id    = module.public_subnet.subnet_id
  environment  = var.environment
  project_name = var.project_name
}

module "private_subnet" {
  source                  = "../../modules/subnet"
  cidr_block              = cidrsubnet(module.vpc.cidr_block, 4, 2)
  project_name            = var.project_name
  vpc_id                  = module.vpc.vpc_id
  environment             = var.environment
  availability_zones      = var.availability_zones
  map_public_ip_on_launch = true
  subnet_count            = var.private_subnet_count
}


module "ecs" {
  source           = "../../modules/ecs"
  ecs_cluster_name = "visitor-chat"
  environment      = var.environment
  project_name     = var.project_name
}