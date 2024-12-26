# data "aws_ssm_parameter" "elasticache_user_group_id" {
#   name = var.elasticache_user_group_id
# }

resource "aws_elasticache_serverless_cache" "cluster" {
  name   = "${var.project_name}-${var.environment}-${var.engine}-cluster"
  engine = var.engine
  cache_usage_limits {
    data_storage {
      maximum = var.cache_storage_max_gb
      unit    = "GB"
    }
    ecpu_per_second {
      maximum = var.ecpu_per_second_max
    }
  }
  daily_snapshot_time  = var.daily_snapshot_time
  description          = "${var.engine} cluster for ${var.environment}"
  major_engine_version = var.major_engine_version
  security_group_ids   = [var.elasticache_sg_id]
  subnet_ids           = var.elasticache_subnet_ids
  ## 2024/12/23時点でValkeyのユーザーグループ/ユーザー作成は未サポートのため、`data`を使ってSSM等から作成済みのユーザーグループ/ユーザーを取得
#   user_group_id = data.aws_ssm_parameter.elasticache_user_group_id.value

  tags = {
    environment  = var.environment
    project_name = var.project_name
  }
}