## Company - Shared間のVPC Peering
resource "aws_vpc_peering_connection" "with_company_ecs" {
  vpc_id      = var.company_chat_vpc_id # リクエストを発行する側
  peer_vpc_id = var.shared_chat_vpc_id  # リクエストを受け取る側
  auto_accept = true                    # 自動でリクエストを承認するかどうか

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  tags = {
    Name        = "shared-company-${var.project_name}-${var.environment}"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_route" "with_company_ecs" {
  route_table_id            = var.company_ecs_route_table_id                 # 既存のルートテーブルID
  destination_cidr_block    = var.company_vpc_cider_block                    # 新しく追加するCIDRブロック
  vpc_peering_connection_id = aws_vpc_peering_connection.with_company_ecs.id # Peering接続ID
}
