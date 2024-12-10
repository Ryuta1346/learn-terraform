resource "aws_subnet" "subnet" {
  count                   = var.subnet_count
  vpc_id                  = var.vpc_id
  cidr_block              = cidrsubnet(var.cidr_block, var.subnet_count, count.index)
  availability_zone       = var.availability_zones[count.index % length(var.availability_zones)]
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = {
    Name        = "${var.project_name}-${var.environment}-${var.private ? "private" : "public"}-subnet-${var.availability_zones[count.index % length(var.availability_zones)]}-${count.index}"
    Environment = var.environment
    Project     = var.project_name
  }
}
