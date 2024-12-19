## Visitor - Shared間のセキュリティグループルール: ECS -> Aurora用
resource "aws_security_group_rule" "visitor_ecs_aurora" {
  type                     = "egress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = var.visitor_ecs_chat_sg_id
  source_security_group_id = var.shared_chat_private_aurora_sg_id
}