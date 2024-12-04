resource "aws_internet_gateway" "igw" {
  vpc_id = var.vpc_id

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}