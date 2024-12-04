module "visitor_chat" {
  source               = "../../services/visitor"
  vpc_cidr_block       = var.visitor_vpc_cidr_block
  availability_zones   = var.availability_zones
  public_subnet_count  = var.visitor_public_subnet_count
  private_subnet_count = var.visitor_private_subnet_count
  environment          = "dev"
  project_name         = var.project_name
}