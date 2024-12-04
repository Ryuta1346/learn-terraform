resource "aws_lb" "visitor_chat" {
  name                       = "visitor-chat"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [var.visitor_chat_alb_sg_id]
  subnets                    = [var.visitor_chat_public_subnet_id]
  enable_deletion_protection = true

  access_logs {
    bucket  = "visitor-chat1-logs"
    prefix  = "visitor-chat1"
    enabled = true
  }

  tags = {
    Environment = var.environment
    Project     = "realtime-chat"
  }

}