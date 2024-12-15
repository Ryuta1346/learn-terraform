## サービス・タスク定義の管理はecspressoで行うため、ここではクラスターのみ定義
resource "aws_ecs_cluster" "cluster" {
  name = var.ecs_cluster_vars.ecs_cluster_name
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_ecs_cluster_capacity_providers" "cluster_capacity_provider" {
  cluster_name       = aws_ecs_cluster.cluster.name
  capacity_providers = var.ecs_cluster_vars.capacity_providers

  default_capacity_provider_strategy {
    base              = var.ecs_cluster_vars.default_base_count
    weight            = var.ecs_cluster_vars.default_weight_count
    capacity_provider = coalesce(var.ecs_cluster_vars.capacity_provider, var.ecs_cluster_vars.capacity_providers[0])
  }
}