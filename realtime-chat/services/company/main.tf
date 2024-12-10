module "vpc" {
  source         = "../../modules/vpc"
  project_name   = var.project_name
  environment    = var.environment
  vpc_cidr_block = var.vpc_cidr_block
}

module "internet_gateway" {
  depends_on   = [module.vpc]
  source       = "../../modules/internet_gateway/"
  vpc_id       = module.vpc.vpc_id
  environment  = var.environment
  project_name = var.project_name
}

module "public_subnet" {
  depends_on              = [module.internet_gateway]
  source                  = "../../modules/subnet"
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 4, 1)
  project_name            = var.project_name
  vpc_id                  = module.vpc.vpc_id
  environment             = var.environment
  availability_zones      = var.availability_zones
  map_public_ip_on_launch = true
  subnet_count            = var.public_subnet_count
  private                 = false
}

module "public_route_table" {
  depends_on   = [module.internet_gateway]
  source       = "../../modules/route_table"
  vpc_id       = module.vpc.vpc_id
  environment  = var.environment
  project_name = var.project_name
  routes = [
    {
      cidr_block = "0.0.0.0/0",
      gateway_id = module.internet_gateway.internet_gateway_id
    }
  ]
}


resource "aws_route_table_association" "association" {
  depends_on     = [module.public_subnet, module.public_route_table]
  for_each       = { for idx, id in module.public_subnet.subnet_ids : idx => id }
  subnet_id      = each.value
  route_table_id = module.public_route_table.route_table_id
}



module "public_alb_sg" {
  source              = "../../modules/security_group"
  security_group_name = "company-chat-public"
  vpc_id              = module.vpc.vpc_id
  environment         = var.environment
  project_name        = var.project_name
}


module "elb" {
  depends_on                 = [module.public_subnet]
  source                     = "../../modules/elb"
  elb_name                   = "company-chat-public"
  vpc_id                     = module.vpc.vpc_id
  alb_sg_id                  = module.public_alb_sg.alb_sg_id
  subnet_ids                 = module.public_subnet.subnet_ids
  environment                = var.environment
  project_name               = var.project_name
  enable_deletion_protection = false
}

module "private_subnet" {
  source                  = "../../modules/subnet"
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 4, 2)
  project_name            = var.project_name
  vpc_id                  = module.vpc.vpc_id
  environment             = var.environment
  availability_zones      = var.availability_zones
  map_public_ip_on_launch = false
  private                 = true
  subnet_count            = var.private_subnet_count
}

module "private_route_table" {
  depends_on   = [module.internet_gateway]
  source       = "../../modules/route_table"
  vpc_id       = module.vpc.vpc_id
  environment  = var.environment
  project_name = var.project_name
  routes = [
    {
      cidr_block = var.vpc_cidr_block,
      gateway_id = "local"
    }
  ]
}


module "ecs" {
  source           = "../../modules/ecs"
  ecs_cluster_name = "company-chat"
  environment      = var.environment
  project_name     = var.project_name
}