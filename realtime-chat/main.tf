// VPC
resource "aws_vpc" "visitor_chat_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name    = "visitor-realtime-chat"
    Project = "realtime-chat"
  }
}

resource "aws_internet_gateway" "visitor_chat_igw" {
  vpc_id = aws_vpc.visitor_chat_vpc.id

  tags = {
    Name    = "visitor-realtime-chat-igw"
    Project = "realtime-chat"
  }

}

resource "aws_subnet" "visitor_chat_public_subnet1" {
  vpc_id                  = aws_vpc.visitor_chat_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name    = "visitor-realtime-chat-public-subnet1"
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
    Name    = "visitor-realtime-chat-public-route-table"
    Project = "realtime-chat"
  }
}

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.visitor_chat_public_subnet1.id
  route_table_id = aws_route_table.public_route_table.id
}



resource "aws_lb" "visitor_chat1" {
  name                       = "visitor-chat1"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.visitor_chat_alb_sg.id]
  subnets                    = [aws_subnet.visitor_chat_public_subnet1.id]
  enable_deletion_protection = true

  access_logs {
    bucket  = "visitor-chat1-logs"
    prefix  = "visitor-chat1"
    enabled = true
  }

}

resource "aws_security_group" "visitor_chat_alb_sg" {
  name        = "visitor-chat-alb-sg"
  description = "Managed for Visitor's Chat"
  vpc_id      = aws_vpc.visitor_chat_vpc.id

  tags = {
    Name    = "visitor-chat-sg"
    Project = "realtime-chat"
  }
}

resource "aws_vpc_security_group_ingress_rule" "https_inbound" {
  security_group_id = aws_security_group.visitor_chat_alb_sg.id
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow HTTPS inbound traffic"
}

resource "aws_vpc_security_group_ingress_rule" "http_inbound" {
  security_group_id = aws_security_group.visitor_chat_alb_sg.id
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow HTTP inbound traffic"
}

resource "aws_vpc_security_group_egress_rule" "all_traffic" {
  security_group_id = aws_security_group.visitor_chat_alb_sg.id
  from_port         = -1
  to_port           = -1
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow all outbound traffic"
}

resource "aws_subnet" "visitor_chat_private_subnet1" {
  vpc_id     = aws_vpc.visitor_chat_vpc.id
  cidr_block = "10.0.100.0/24"

  tags = {
    Name    = "visitor-realtime-chat-private-subnet1"
    Project = "realtime-chat"
  }
}

resource "aws_ecs_cluster" "visitor_chat" {
  name = "visitor-chat"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "visitor_chat" {
  cluster_name       = aws_ecs_cluster.visitor_chat.name
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 2
    capacity_provider = "FARGATE"
  }
}