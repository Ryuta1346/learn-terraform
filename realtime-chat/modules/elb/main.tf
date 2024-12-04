resource "aws_lb" "chat" {
  name                       = "visitor-chat"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [var.alb_sg_id]
  subnets                    = [var.public_subnet_id]
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