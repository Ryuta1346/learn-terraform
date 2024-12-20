resource "aws_vpc_endpoint" "endpoint" {
  vpc_id              = var.vpc_id
  service_name        = var.service_name
  vpc_endpoint_type   = var.endpoint_type
  security_group_ids  = var.security_group_ids
  subnet_ids          = var.subnet_ids
  private_dns_enabled = true

  tags = {
    Name        = var.name
    Environment = var.environment
    Project     = var.project_name
  }
}