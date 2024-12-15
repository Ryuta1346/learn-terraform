## サービス・タスク定義の管理はecspressoで行うため、ここではクラスターのみ定義
resource "aws_ecs_cluster" "cluster" {
  for_each = { for ecs_cluster in var.ecs_cluster_vars : ecs_cluster.ecs_cluster_name => ecs_cluster }
  name     = each.value.ecs_cluster_name
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
  for_each           = { for ecs_cluster in var.ecs_cluster_vars : ecs_cluster.ecs_cluster_name => ecs_cluster }
  cluster_name       = aws_ecs_cluster.cluster[each.key].name
  capacity_providers = each.value.capacity_providers

  default_capacity_provider_strategy {
    base              = var.ecs_cluster_vars[each.key].default_base_count
    weight            = var.ecs_cluster_vars[each.key].default_weight_count
    capacity_provider = each.value.capacity_provider ? each.value.capacity_provider : var.ecs_cluster_vars[each.key].capacity_providers[0]
  }
}