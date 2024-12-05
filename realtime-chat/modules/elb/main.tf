resource "aws_lb" "elb" {
  name                       = "${var.elb_name}-elb"
  internal                   = var.internal
  load_balancer_type         = var.load_balancer_type
  security_groups            = [var.alb_sg_id]
  subnets                    = var.subnet_ids
  enable_deletion_protection = var.enable_deletion_protection
  timeouts {
    create = "60m"
    update = "60m"
    delete = "60m"
  }

  # access_logs {
  #   bucket  = "${var.elb_name}-elb"
  #   prefix  = var.environment
  #   enabled = var.access_logs_enabled
  # }

  tags = {
    # Name        = "${var.project_name}-${var.environment}-elb"
    Environment = var.environment
    Project     = var.project_name
  }
}