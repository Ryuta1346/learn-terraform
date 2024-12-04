## サービス・タスク定義の管理はecspressoで行うため、ここではクラスターのみ定義
resource "aws_ecs_cluster" "chat" {
  name = "chat"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Environment = var.environment
    Project     = "realtime-chat"
  }
}

resource "aws_ecs_cluster_capacity_providers" "chat" {
  cluster_name       = aws_ecs_cluster.chat.name
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 2
    capacity_provider = "FARGATE"
  }
}