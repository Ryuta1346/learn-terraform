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

  type                     = "ingress"
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  cidr_blocks              = lookup(each.value, "cidr_blocks", [])
  security_group_id        = aws_security_group.sg.id
  source_security_group_id = lookup(each.value, "source_security_group_id", null)
  description              = each.value.description
}


resource "aws_security_group_rule" "egress" {
  for_each = { for idx, rule in var.sg_rules.egress_rules : idx => rule }

  type                     = "egress"
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  cidr_blocks              = lookup(each.value, "cidr_blocks", [])
  security_group_id        = aws_security_group.sg.id
  source_security_group_id = lookup(each.value, "source_security_group_id", null)
  description              = each.value.description
}
