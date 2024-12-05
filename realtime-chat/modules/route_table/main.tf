resource "aws_route_table" "table" {
  vpc_id = var.vpc_id

  # route {
  #   cidr_block = var.route_table_cidr_block
  #   gateway_id = var.internet_gateway_id
  # }
  dynamic "route" {
    for_each = var.routes
    content {
      cidr_block     = route.value.cidr_block
      gateway_id     = route.value.gateway_id
      nat_gateway_id = route.value.nat_gateway_id
      # transit_gateway_id = route.value.transit_gateway_id
    }
  }


  tags = {
    Name        = "${var.project_name}-${var.environment}-route-table"
    Environment = var.environment
    Project     = var.project_name
  }
}

# resource "aws_route_table_association" "association" {
#   subnet_id      = var.subnet_id
#   route_table_id = aws_route_table.table.id
# }

