## サービス・タスク定義の管理はecspressoで行うため、ここではクラスターのみ定義
resource "aws_ecs_cluster" "visitor_chat" {
  name = "visitor-chat"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "visitor_chat" {
  cluster_name       = aws_ecs_cluster.visitor_chat.name
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 2
    capacity_provider = "FARGATE"
  }
}