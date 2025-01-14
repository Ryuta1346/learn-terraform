resource "aws_internet_gateway" "igw" {
  vpc_id = var.vpc_id
  timeouts {
    create = "60m"
    update = "60m"
    delete = "60m"
  }

  tags = {
    Name        = var.gateway_name
    Environment = var.environment
    Project     = var.project_name
  }
}