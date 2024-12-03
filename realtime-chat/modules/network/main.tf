resource "aws_vpc" "visitor_chat_vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name    = "visitor-chat"
    Project = "realtime-chat"
  }
}

resource "aws_internet_gateway" "visitor_chat_igw" {
  vpc_id = aws_vpc.visitor_chat_vpc.id

  tags = {
    Name    = "visitor-chat-igw"
    Project = "realtime-chat"
  }
}

resource "aws_subnet" "visitor_chat_public_subnet" {
  count                   = 3
  vpc_id                  = aws_vpc.visitor_chat_vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 3, count.index)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name    = "visitor-chat-public-subnet-${count.index}"
    Project = "realtime-chat"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.visitor_chat_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.visitor_chat_igw.id
  }

  tags = {
    Name    = "visitor-chat-public-route-table"
    Project = "realtime-chat"
  }
}

resource "aws_route_table_association" "public" {
  for_each       = toset(aws_subnet.visitor_chat_public_subnet[*].id)
  subnet_id      = each.value
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_subnet" "visitor_chat_private_subnet" {
  count             = 3
  vpc_id            = aws_vpc.visitor_chat_vpc.id
  availability_zone = var.availability_zones[count.index]
  cidr_block        = cidrsubnet(var.vpc_cidr_block, 3, count.index + 3)

  tags = {
    Name    = "visitor-chat-private-subnet-${count.index}"
    Project = "realtime-chat"
  }
}