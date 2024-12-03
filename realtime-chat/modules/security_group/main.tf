resource "aws_security_group" "visitor_chat_alb_sg" {
  name        = "visitor-chat-alb-sg"
  description = "Managed for Visitor's Chat"
  vpc_id      = var.visitor_chat_vpc_id

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