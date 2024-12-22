## Company - Shared間のセキュリティグループルール: ECS -> Aurora用
resource "aws_security_group_rule" "company_ecs_aurora_egress" {
  depends_on = [ aws_vpc_peering_connection.with_company_ecs ]
  type                     = "egress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = var.company_ecs_chat_sg_id
  source_security_group_id = var.shared_chat_private_aurora_sg_id
}

resource "aws_security_group_rule" "company_ecs_aurora_ingress" {
  depends_on = [ aws_vpc_peering_connection.with_company_ecs ]
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = var.shared_chat_private_aurora_sg_id
  source_security_group_id = var.company_ecs_chat_sg_id
}