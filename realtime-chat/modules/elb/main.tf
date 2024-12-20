resource "aws_lb" "elb" {
  for_each                   = { for elb in var.elb_vars : elb.elb_name => elb }
  name                       = "${var.project_name}-${var.environment}-${each.value.elb_name}"
  internal                   = each.value.internal
  load_balancer_type         = each.value.load_balancer_type
  security_groups            = each.value.security_group_ids
  subnets                    = each.value.subnet_ids
  enable_deletion_protection = each.value.enable_deletion_protection
  timeouts {
    create = "60m"
    update = "60m"
    delete = "60m"
  }

  # access_logs {
  #   bucket  = "${each.value.name}-elb"
  #   prefix  = var.environment
  #   enabled = each.value.access_logs_enabled
  # }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}