resource "aws_security_group_rule" "company_ecs_elasticache_egress1" {
  depends_on               = [aws_vpc_peering_connection.with_company_ecs]
  type                     = "egress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  security_group_id        = var.company_ecs_chat_sg_id
  source_security_group_id = var.shared_chat_private_elasticache_sg_id
}

resource "aws_security_group_rule" "company_ecs_elasticache_egress2" {
  depends_on               = [aws_vpc_peering_connection.with_company_ecs]
  type                     = "egress"
  from_port                = 6380
  to_port                  = 6380
  protocol                 = "tcp"
  security_group_id        = var.company_ecs_chat_sg_id
  source_security_group_id = var.shared_chat_private_elasticache_sg_id
}


resource "aws_security_group_rule" "company_ecs_elasticache_ingress1" {
  depends_on               = [aws_vpc_peering_connection.with_company_ecs]
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  security_group_id        = var.shared_chat_private_elasticache_sg_id
  source_security_group_id = var.company_ecs_chat_sg_id
}


resource "aws_security_group_rule" "company_ecs_elasticache_ingress2" {
  depends_on               = [aws_vpc_peering_connection.with_company_ecs]
  type                     = "ingress"
  from_port                = 6380
  to_port                  = 6380
  protocol                 = "tcp"
  security_group_id        = var.shared_chat_private_elasticache_sg_id
  source_security_group_id = var.company_ecs_chat_sg_id
}