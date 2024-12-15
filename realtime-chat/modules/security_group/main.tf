resource "aws_security_group" "sg" {
  name        = "${var.security_group_name}-sg"
  description = var.description
  vpc_id      = var.vpc_id

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_security_group_rule" "ingress" {
  for_each = { for idx, rule in var.sg_rules.ingress_rules : idx => rule }

  type              = "ingress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  security_group_id = aws_security_group.sg.id
  description       = each.value.description

  source_security_group_id = contains(keys(each.value), "source_security_group_id") ? each.value.source_security_group_id : null
  cidr_blocks              = contains(keys(each.value), "cidr_blocks") && !contains(keys(each.value), "source_security_group_id") ? each.value.cidr_blocks : null
}

resource "aws_security_group_rule" "egress" {
  for_each = { for idx, rule in var.sg_rules.egress_rules : idx => rule }

  type              = "egress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  security_group_id = aws_security_group.sg.id
  description       = each.value.description

  source_security_group_id = contains(keys(each.value), "source_security_group_id") ? each.value.source_security_group_id : null
  cidr_blocks              = contains(keys(each.value), "cidr_blocks") && !contains(keys(each.value), "source_security_group_id") ? each.value.cidr_blocks : null
}