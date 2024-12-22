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

resource "aws_db_subnet_group" "aurora_subnet_group" {
  name        = "${var.project_name}-${var.environment}-aurora-subnet-group"
  description = "Subnet group for Aurora MySQL cluster for ${var.project_name}-${var.environment}"
  subnet_ids  = module.private_aurora_subnet.subnet_ids

  tags = {
    Environment = "dev"
    Project     = "OPTEMO"
  }
}

resource "aws_rds_cluster_parameter_group" "realtime_chats" {
  name        = "${var.project_name}-${var.environment}-cluster-parameter-group"
  family      = "aurora-mysql8.0" # 対応するエンジンとバージョン
  description = "Custom parameter group for Aurora MySQL 8"
  parameter {
    name         = "character_set_server"
    value        = "utf8mb4"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "slow_query_log"
    value        = "1"
    apply_method = "immediate"
  }
}

resource "aws_rds_cluster" "realtime_chats_cluster" {
  depends_on                      = [aws_rds_cluster_parameter_group.realtime_chats]
  cluster_identifier              = "${var.project_name}-${var.environment}-cluster"
  engine                          = "aurora-mysql"
  engine_version                  = "8.0.mysql_aurora.3.07.1"
  database_name                   = "realtime_chats_${var.environment}"
  master_username                 = "admin"
  master_password                 = "password"
  db_subnet_group_name            = aws_db_subnet_group.aurora_subnet_group.name
  vpc_security_group_ids          = [module.private_aurora_sg.sg_id]
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.realtime_chats.name
  skip_final_snapshot             = true
  # backup_retention_period         = 0
  # storage_encrypted = true
  # storage_encryption_key = module.kms.key_arn
  tags = {
    Name    = "${var.project_name}-${var.environment}"
    Project = var.project_name
    Env     = var.environment
  }
}

resource "aws_rds_cluster_instance" "instance1" {
  identifier         = "${var.project_name}-${var.environment}-instance1"
  cluster_identifier = aws_rds_cluster.realtime_chats_cluster.id
  instance_class     = "db.t3.medium"
  engine             = aws_rds_cluster.realtime_chats_cluster.engine
  engine_version     = aws_rds_cluster.realtime_chats_cluster.engine_version
  availability_zone  = var.availability_zones[0]
  # ca_cert_identifier           = "rds-ca-2019"
  auto_minor_version_upgrade   = true
  performance_insights_enabled = false
  # monitoring_interval          = 60
  # monitoring_role_arn          = "" // RDSが拡張モニタリングメトリクスをCloudWatch Logsに送信することを許可するIAMロールのARN

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}
