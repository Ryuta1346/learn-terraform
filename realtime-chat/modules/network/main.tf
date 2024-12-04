resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Environment = var.environment
    Project     = "realtime-chat"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Environment = var.environment
    Project     = "realtime-chat"
  }
}

resource "aws_subnet" "public_subnet" {
  count                   = 3
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 3, count.index)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Environment = var.environment
    Project     = "realtime-chat"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Environment = var.environment
    Project     = "realtime-chat"
  }
}

resource "aws_route_table_association" "public" {
  depends_on     = [aws_subnet.public_subnet]
  for_each       = { for idx, subnet in aws_subnet.public_subnet : idx => subnet.id }
  subnet_id      = each.value
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_subnet" "private_subnet" {
  count             = 3
  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.availability_zones[count.index]
  cidr_block        = cidrsubnet(var.vpc_cidr_block, 3, count.index + 3)

  tags = {
    Environment = var.environment
    Project     = "realtime-chat"
  }
}