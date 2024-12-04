resource "aws_lb" "elb" {
  name                       = "${var.elb_name}-elb"
  internal                   = var.internal
  load_balancer_type         = var.load_balancer_type
  security_groups            = [var.alb_sg_id]
  subnets                    = [var.subnet_id]
  enable_deletion_protection = var.enable_deletion_protection

  access_logs {
    bucket  = "${var.elb_name}-elb"
    prefix  = var.environment
    enabled = var.access_logs_enabled
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}