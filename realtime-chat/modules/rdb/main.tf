

resource "aws_db_subnet_group" "subnet_group" {
  name        = var.db_subnet_group.name
  description = var.db_subnet_group.description
  subnet_ids  = var.db_subnet_group.subnet_ids

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_rds_cluster_parameter_group" "cluster_parameter_group" {
  name        = var.cluster_parameter_group.name
  family      = var.cluster_parameter_group.family # 対応するエンジンとバージョン
  description = var.cluster_parameter_group.description
  for_each    = { for idx, parameter in var.cluster_parameter_group.parameters : idx => parameter }
  parameter {
    name         = each.value.parameter.name
    value        = each.value.parameter.value
    apply_method = each.value.parameter.apply_method
  }
}


// [Resource: aws_kms_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key)
resource "aws_kms_key" "rds_cluster" {
  description             = var.kms_parameters.description
  enable_key_rotation     = var.kms_parameters.enable_key_rotation // 本番運用の際には原則trueで運用する
  rotation_period_in_days = var.kms_parameters.rotation_period_in_days
  is_enabled              = var.kms_parameters.is_enabled
  deletion_window_in_days = var.kms_parameters.deletion_window_in_days
  multi_region            = var.kms_parameters.multi_region // default: false

  tags = {
    Name        = var.kms_parameters.name
    Environment = var.environment
    Project     = var.project_name
  }
}

// 事前に作成しておく `aws ssm put-parameter --name "/example/path/value" --type "SecureString" --value "password-value" --description "description" --region "region-name"" `
data "aws_ssm_parameter" "master_password" {
  name = var.ssm_master_password_path
}

resource "aws_rds_cluster" "cluster" {
  depends_on                      = [aws_rds_cluster_parameter_group.cluster_parameter_group]
  cluster_identifier              = var.rds_cluster_parameter.cluster_identifier
  deletion_protection             = var.rds_cluster_parameter.deletion_protection // 本番運用の際にはtrueで運用する
  engine                          = var.rds_cluster_parameter.engine
  engine_version                  = var.rds_cluster_parameter.engine_version
  database_name                   = var.rds_cluster_parameter.database_name
  master_username                 = var.rds_cluster_parameter.master_username
  master_password                 = data.aws_ssm_parameter.master_password.value // 本番運用の際にはmanage_master_user_passwordをtrueとし、Secrets Managerで管理する
  db_subnet_group_name            = aws_db_subnet_group.subnet_group.name
  vpc_security_group_ids          = var.rds_cluster_parameter.security_group_ids
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.cluster_parameter_group.name
  performance_insights_enabled    = var.rds_cluster_parameter.performance_insights_enabled
  storage_type                    = var.rds_cluster_parameter.storage_type
  skip_final_snapshot             = var.rds_cluster_parameter.skip_final_snapshot
  storage_encrypted               = var.rds_cluster_parameter.storage_encrypted
  kms_key_id                      = aws_kms_key.rds_cluster.arn
  preferred_backup_window         = var.rds_cluster_parameter.preferred_backup_window
  preferred_maintenance_window    = var.rds_cluster_parameter.preferred_maintenance_window

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_rds_cluster_instance" "instance" {
  count                        = var.cluster_instance.count
  identifier                   = "${aws_rds_cluster.cluster.cluster_identifier}-instance${count.index}"
  cluster_identifier           = aws_rds_cluster.cluster.id
  instance_class               = var.cluster_instance.instance_class
  engine                       = aws_rds_cluster.cluster.engine
  engine_version               = aws_rds_cluster.cluster.engine_version
  availability_zone            = element(var.cluster_instance.availability_zones, count.index)
  auto_minor_version_upgrade   = true
  performance_insights_enabled = false
  # ca_cert_identifier           = "rds-ca-2019"
  # monitoring_interval          = 60
  # monitoring_role_arn          = "" // RDSが拡張モニタリングメトリクスをCloudWatch Logsに送信することを許可するIAMロールのARN

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}
