resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name        = "${var.project_name}-${var.environment}-nat-eip"
    project     = var.project_name
    environment = var.environment
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  depends_on    = [aws_eip.nat_eip]
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = var.subnet_id
}