// 開発用途のため小さな範囲でVPCを分割
visitor_vpc_cidr_block       = "10.0.0.0/22"
visitor_public_subnet_count  = 2
visitor_private_subnet_count = 1
company_vpc_cidr_block       = "10.0.4.0/22"
company_public_subnet_count  = 2
company_private_subnet_count = 1
shared_vpc_cidr_block        = "10.0.8.0/22"
availability_zones           = ["us-east-1a", "us-east-1b", "us-east-1c"]
project_name                 = "realtime-chat"