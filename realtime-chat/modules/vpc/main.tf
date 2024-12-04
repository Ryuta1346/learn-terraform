resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}
