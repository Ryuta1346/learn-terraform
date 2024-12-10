## サービス・タスク定義の管理はecspressoで行うため、ここではクラスターのみ定義
resource "aws_ecs_cluster" "chat" {
  name = var.ecs_cluster_name
  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-ecs-cluster"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_ecs_cluster_capacity_providers" "chat" {
  cluster_name       = aws_ecs_cluster.chat.name
  capacity_providers = var.capacity_providers

  default_capacity_provider_strategy {
    base              = var.default_base_count
    weight            = var.default_weight_count
    capacity_provider = var.capacity_providers[0]
  }
}

