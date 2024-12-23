## Aurora用
module "private_aurora_subnet" {
  source = "../../modules/subnet"
  subnet_vars = [
    {
      id                      = "${var.project_name}-${var.environment}-aurora1"
      vpc_id                  = module.vpc.vpc_id
      availability_zone       = var.availability_zones[0]
      cidr_block              = cidrsubnet(var.vpc_cidr_block, 4, local.subnets.aurora1)
      map_public_ip_on_launch = false
      is_private              = true
    },
    {
      id                      = "${var.project_name}-${var.environment}-aurora2"
      vpc_id                  = module.vpc.vpc_id
      availability_zone       = var.availability_zones[1]
      cidr_block              = cidrsubnet(var.vpc_cidr_block, 4, local.subnets.aurora2)
      map_public_ip_on_launch = false
      is_private              = true
    }
  ]
  environment  = var.environment
  project_name = var.project_name
}

module "private_aurora_sg" {
  source              = "../../modules/security_group"
  vpc_id              = module.vpc.vpc_id
  security_group_name = "private-aurora-sg"
  description         = "Security group for the private subnet of Aurora"
  sg_rules = {
    ingress_rules = [
      {
        from_port                = 80
        to_port                  = 80
        protocol                 = "tcp"
        source_security_group_id = module.chat_persistence_lambda_sg.sg_id
      },
      {
        from_port                = 443
        to_port                  = 443
        protocol                 = "tcp"
        source_security_group_id = module.chat_persistence_lambda_sg.sg_id
      },
    ],
    egress_rules = [
      {
        from_port                = 0
        to_port                  = 0
        protocol                 = "-1"
        source_security_group_id = module.chat_persistence_lambda_sg.sg_id
    }]
  }
  environment  = var.environment
  project_name = var.project_name
}

module "private_aurora_route_table" {
  source       = "../../modules/route_table"
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.private_aurora_subnet.subnet_ids
  environment  = var.environment
  project_name = var.project_name
  routes = [
    {
      cidr_block = var.vpc_cidr_block,
      gateway_id = "local"
    }
  ]
}

module "realtime_chat_rds_cluster" {
  source       = "../../modules/rdb"
  project_name = var.project_name
  environment  = var.environment
  db_subnet_group = {
    name        = "${var.project_name}-${var.environment}-aurora-subnet-group"
    description = "Subnet group for Aurora MySQL cluster for ${var.project_name}-${var.environment}"
    subnet_ids  = module.private_aurora_subnet.subnet_ids
  }

  cluster_parameter_group = {
    name        = "${var.project_name}-${var.environment}-cluster-parameter-group"
    family      = "aurora-mysql8.0"
    description = "Custom parameter group for Aurora MySQL 8"
    parameter = [
      {
        name         = "character_set_server"
        value        = "utf8mb4"
        apply_method = "pending-reboot"
      },
      {
        name         = "slow_query_log"
        value        = "1"
        apply_method = "immediate"
      }
    ]
  }

  kms_parameters = {
    name                    = "${var.project_name}-${var.environment}-aurora"
    description             = "KMS key for Aurora MySQL cluster for ${var.project_name}-${var.environment}"
    enable_key_rotation     = false
    rotation_period_in_days = 180
    is_enabled              = true
    deletion_window_in_days = 30
    multi_region            = false
  }

  ssm_master_password_path = "/aurora/realtime-chat/dev/password"
  rds_cluster_parameter = {
    name                         = "${var.project_name}-${var.environment}-cluster"
    cluster_identifier           = "${var.project_name}-${var.environment}-cluster"
    deletion_protection          = false
    security_group_ids           = [module.private_aurora_sg.sg_id]
    engine                       = "aurora-mysql"
    engine_version               = "8.0.mysql_aurora.3.08.0"
    database_name                = "realtime_chats_${var.environment}"
    master_username              = "admin"
    performance_insights_enabled = true
    storage_type                 = "aurora-iopt1"
    skip_final_snapshot          = true
    storage_encrypted            = true
    preferred_backup_window      = "03:00-04:00"
    preferred_maintenance_window = "Mon:02:00-Mon:03:00"
  }
  cluster_instance = {
    count                        = 2
    instance_class               = "db.t3.medium"
    availability_zones           = var.availability_zones
    auto_minor_version_upgrade   = true
    performance_insights_enabled = false
  }

}

# resource "aws_db_subnet_group" "aurora_subnet_group" {
#   name        = "${var.project_name}-${var.environment}-aurora-subnet-group"
#   description = "Subnet group for Aurora MySQL cluster for ${var.project_name}-${var.environment}"
#   subnet_ids  = module.private_aurora_subnet.subnet_ids

#   tags = {
#     Environment = var.environment
#     Project     = var.project_name
#   }
# }

# resource "aws_rds_cluster_parameter_group" "realtime_chats" {
#   name        = "${var.project_name}-${var.environment}-cluster-parameter-group"
#   family      = "aurora-mysql8.0" # 対応するエンジンとバージョン
#   description = "Custom parameter group for Aurora MySQL 8"
#   parameter {
#     name         = "character_set_server"
#     value        = "utf8mb4"
#     apply_method = "pending-reboot"
#   }

#   parameter {
#     name         = "slow_query_log"
#     value        = "1"
#     apply_method = "immediate"
#   }
# }

// [Resource: aws_kms_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key)
# resource "aws_kms_key" "aurora_realtime_chats" {
#   description             = "KMS key for Aurora MySQL cluster for ${var.project_name}-${var.environment}"
#   enable_key_rotation     = false // 本番運用の際には原則trueで運用する
#   rotation_period_in_days = 180
#   is_enabled              = true
#   deletion_window_in_days = 30
#   multi_region            = false // default: false

#   tags = {
#     Name        = "${var.project_name}-${var.environment}-aurora"
#     Environment = var.environment
#     Project     = var.project_name
#   }
# }

# // 事前に作成しておく `aws ssm put-parameter --name "/example/path/value" --type "SecureString" --value "password-value" --description "description" --region "region-name"" `
# # data "aws_ssm_parameter" "master_password" {
# #   name = "/aurora/realtime-chat/dev/password"
# # }

# resource "aws_rds_cluster" "realtime_chats_cluster" {
#   depends_on                      = [aws_rds_cluster_parameter_group.realtime_chats]
#   cluster_identifier              = "${var.project_name}-${var.environment}-cluster"
#   deletion_protection             = false // 本番運用の際にはtrueで運用する
#   engine                          = "aurora-mysql"
#   engine_version                  = "8.0.mysql_aurora.3.08.0"
#   database_name                   = "realtime_chats_${var.environment}"
#   master_username                 = "admin"
#   master_password                 = data.aws_ssm_parameter.master_password.value // 本番運用の際にはmanage_master_user_passwordをtrueとし、Secrets Managerで管理する
#   db_subnet_group_name            = aws_db_subnet_group.aurora_subnet_group.name
#   vpc_security_group_ids          = [module.private_aurora_sg.sg_id]
#   db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.realtime_chats.name
#   performance_insights_enabled    = true
#   storage_type                    = "aurora-iopt1"
#   skip_final_snapshot             = true
#   storage_encrypted               = true
#   kms_key_id                      = aws_kms_key.aurora_realtime_chats.arn
#   preferred_backup_window         = "03:00-04:00"
#   preferred_maintenance_window    = "Mon:02:00-Mon:03:00"
#   tags = {
#     Name        = "${var.project_name}-${var.environment}"
#     Project     = var.project_name
#     Environment = var.environment
#   }
# }

# resource "aws_rds_cluster_instance" "instance" {
#   count                        = local.instance_count
#   identifier                   = "${var.project_name}-${var.environment}-instance${count.index}"
#   cluster_identifier           = aws_rds_cluster.realtime_chats_cluster.id
#   instance_class               = "db.t3.medium"
#   engine                       = aws_rds_cluster.realtime_chats_cluster.engine
#   engine_version               = aws_rds_cluster.realtime_chats_cluster.engine_version
#   availability_zone            = element(var.availability_zones, count.index)
#   auto_minor_version_upgrade   = true
#   performance_insights_enabled = false
#   # ca_cert_identifier           = "rds-ca-2019"
#   # monitoring_interval          = 60
#   # monitoring_role_arn          = "" // RDSが拡張モニタリングメトリクスをCloudWatch Logsに送信することを許可するIAMロールのARN

#   tags = {
#     Environment = var.environment
#     Project     = var.project_name
#   }
# }
