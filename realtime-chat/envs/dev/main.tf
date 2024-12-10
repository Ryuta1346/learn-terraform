# module "backup" {
#   source = "../../backup"
# }

module "visitor_chat" {
  source               = "../../services/visitor"
  vpc_cidr_block       = var.visitor_vpc_cidr_block
  availability_zones   = var.availability_zones
  public_subnet_count  = var.visitor_public_subnet_count
  private_subnet_count = var.visitor_private_subnet_count
  environment          = "dev"
  project_name         = "${var.project_name}-visitor"
}

module "company_chat" {
  source               = "../../services/company"
  vpc_cidr_block       = var.company_vpc_cidr_block
  availability_zones   = var.availability_zones
  public_subnet_count  = var.company_public_subnet_count
  private_subnet_count = var.company_private_subnet_count
  environment          = "dev"
  project_name         = "${var.project_name}-company"
}

module "shared" {
  depends_on           = [module.visitor_chat]
  source               = "../../services/shared"
  project_name         = "${var.project_name}-shared"
  environment          = "dev"
  vpc_cidr_block       = var.shared_vpc_cidr_block
  availability_zones   = var.availability_zones
  public_subnet_count  = var.shared_public_subnet_count
  private_subnet_count = var.shared_private_subnet_count
  visitor_chat_sg_id   = module.visitor_chat.visitor_ecs_sg_id
  region               = var.region
}