resource "aws_subnet" "subnet" {
  for_each                = { for subnet in var.subnet_vars : subnet.id => subnet }
  vpc_id                  = each.value.vpc_id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = each.value.map_public_ip_on_launch

  tags = {
    Name        = each.value.id
    # Name        = "${var.project_name}-${var.environment}-${each.value.is_private ? "private" : "public"}-${each.value.availability_zone}"
    Environment = var.environment
    Project     = var.project_name
  }
}
