terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "ap-northeast-1"
}


// [Resource: aws_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc)
resource "aws_vpc" "VPC" {
  cidr_block = "10.0.0.0/16" // CIDR表記で、今回はネットワークのビット長を16ビットに設定
  tags = {
    Name = "aws-network-server-VPC"
  }
}

// 公開用サブネット
// [Resource: aws_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)
resource "aws_subnet" "public1" {
  vpc_id     = aws_vpc.VPC.id
  cidr_block = "10.0.1.0/24"
  # map_public_ip_on_launch = true // サブネットに起動したインスタンスにパブリックIPアドレスを割り当てる場合はtrueを指定する。 デフォルトはfalse
  tags = {
    Name = "aws-network-server-subnet-public1"
  }
}

// [Resource: aws_internet_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway)
resource "aws_internet_gateway" "test-internet-gateway" {
  vpc_id = aws_vpc.VPC.id
  tags = {
    Name = "aws-network-server-test-internet-gateway"
  }
}

// [Resource: aws_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table#example-usage)
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test-internet-gateway.id
  }
  tags = {
    Name = "aws-network-server-public-route-table"
  }
}

// 公開用サブネットとルートテーブルの関連付け
// [Resource: aws_route_table_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association)
resource "aws_route_table_association" "public-subnet-association" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public-route-table.id
}

// AMIの一覧取得: aws ssm get-parameters-by-path --path /aws/service/ami-amazon-linux-latest --query 'Parameters[].Name'
data "aws_ssm_parameter" "amazonlinux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64" // Amazon Linux 2023の最新のAMI IDを取得
}


// 任意のAMIを指定する場合は以下のように記述する
# data "aws_ami" "amazon-linux-2023" {
#   most_recent = true
#   owners      = ["amazon"]
#   filter {
#     name   = "name"
#     values = ["al2023-ami-*-kernel-6.1-x86_64"]
#   }
# }

resource "aws_instance" "web-server" {
  ami                         = data.aws_ssm_parameter.amazonlinux_2023.value
  instance_type               = "t2.micro"
  private_ip                  = "10.0.1.10"                          // 指定しない場合、パブリックサブネットに割り当てた「10.0.1.0~10.0.1.255」の範囲内でインスタンス起動時に自動で割り当てられる。今回は手動で指定
  subnet_id                   = aws_subnet.public1.id                // 外部公開用サブネットにインスタンスを配置
  associate_public_ip_address = true                                 // 外部からのアクセス用にパブリックIPを自動で割り当てる
  vpc_security_group_ids      = [aws_security_group.web-sg.id]       // EC2インスタンスに適用するセキュリティグループを指定
  key_name                    = aws_key_pair.web-server-key.key_name // EC2インスタンスに適用するキーペアを指定.SSH接続を行うために必要
  tags = {
    Name = "aws-network-server-web-server"
  }
}

// 上記で生成したインスタンスで利用する仮想ディスク(EBS: Elastic Block Store)を作成する
resource "aws_ebs_volume" "web-server-volume" {
  availability_zone = aws_instance.web-server.availability_zone
  size              = 8
  type              = "gp2" // default: gp2
  tags = {
    Name = "aws-network-server-web-server-volume"
  }
}

// 作成したインスタンスとEBSを紐付ける
// [Resource: aws_volume_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/volume_attachment)
resource "aws_volume_attachment" "web-server-attachment" {
  device_name = "/dev/sdh"
  instance_id = aws_instance.web-server.id
  volume_id   = aws_ebs_volume.web-server-volume.id
}

// このリソースで生成された秘密鍵は、Terraformのステートファイルに暗号化されずに保存される。
// 今回の実装では本運用しない設定のため、`tls-private_key`を使用しているが、本運用の際にはセキュアな方法で秘密鍵を管理する
// [tls_private_key (Resource)](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key)
resource "tls_private_key" "web-server-key" {
  algorithm = "ED25519" // RSAだとキーの長さ制限にかかることがあるため、ED25519を使用
}

// 上記で生成した秘密鍵をローカルファイルに保存する
// [local_file (Resource)](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file)
resource "local_file" "private" {
  filename        = "id_ed25519_aws_network_server"
  content         = tls_private_key.web-server-key.private_key_openssh
  file_permission = "0600"
}

// 上記で生成した秘密鍵を使用して、AWSのキーペアを作成する。これをEC2インスタンスに紐付けることで、SSH接続を行うことができるようにする
// [Resource: aws_key_pair](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair)
resource "aws_key_pair" "web-server-key" {
  key_name   = "by_terraform"
  public_key = tls_private_key.web-server-key.public_key_openssh
}

// [Resource: aws_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)
resource "aws_security_group" "web-sg" {
  name        = "web-sg"
  description = "Maneged by Terraform!"
  vpc_id      = aws_vpc.VPC.id // セキュリティグループを作成する対象のVPCを指定
  tags = {
    Name = "aws-network-server-web-sg"
  }
}

// ec2インスタンスにssh接続を許可するためのセキュリティグループルールを設定する。resourceにはaws_security_group_ruleを使用しないこと
// [Resource: aws_vpc_security_group_ingress_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule)
resource "aws_vpc_security_group_ingress_rule" "web-sg-ssh" {
  security_group_id = aws_security_group.web-sg.id
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = "125.205.33.111/32" // SSH接続を許可するIPアドレスを指定.全てのIPアドレスを許可する場合は"0.0.0.0/0"を指定
  description       = "Allow SSH from my IP"
}
// dnfコマンドを使用して、外部からhttpsなどWebサーバーソフトウェアをインストールする場合等に必要

/**
 * ec2インスタンスから外部への通信を許可するためのセキュリティグループルールを設定する。resourceにはaws_security_group_ruleを使用しないこと
 * セキュリティグループは、デフォルトですべてのアウトバウンド通信を許可することもあり、書籍上では設定する記述はなかったが、
 * `aws_vpc_security_group_ingress(egress)_rule`を使って個別にルールを設定すると、セキュリティグループのデフォルトルールが無効化されるため、追加設定が必要
 */
resource "aws_vpc_security_group_egress_rule" "all_traffic_rule" {
  security_group_id = aws_security_group.web-sg.id
  from_port         = -1          // すべてのポート（0から65535まで）を許可。
  to_port           = -1          // すべてのポート（0から65535まで）を許可。
  ip_protocol       = "-1"        // すべてのプロトコル
  cidr_ipv4         = "0.0.0.0/0" // すべての宛先に送信を許可
  description       = "Allow all outbound traffic"
}