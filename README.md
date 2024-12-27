## Overview
Terraform を用いたインフラ管理を行うにあたり各種チュートリアルや特定用途での実装例置き場。

## Table of Contents
### [aws-network-server](https://github.com/Ryuta1346/learn-terraform/tree/main/aws-network-server)
書籍[『Amazon Web Services基礎からのネットワーク＆サーバー構築改訂４版』](https://www.amazon.co.jp/Amazon-Web-Services%E5%9F%BA%E7%A4%8E%E3%81%8B%E3%82%89%E3%81%AE%E3%83%8D%E3%83%83%E3%83%88%E3%83%AF%E3%83%BC%E3%82%AF%EF%BC%86%E3%82%B5%E3%83%BC%E3%83%90%E3%83%BC%E6%A7%8B%E7%AF%89%E6%94%B9%E8%A8%82%EF%BC%94%E7%89%88-%E5%A4%A7%E6%BE%A4-%E6%96%87%E5%AD%9D/dp/4296202049/ref=sr_1_3?__mk_ja_JP=%E3%82%AB%E3%82%BF%E3%82%AB%E3%83%8A&crid=1M4MRW7T80ID8&dib=eyJ2IjoiMSJ9.rPzBN5zjAtsK61sQCjVjHRK4YOuYbqSjLBscH3PYypkY-EN3HJTssSNaknRttgnY9yHML-FgGOpJE7T4LoZ4rU4jK1ozqbOP27-G-P1JKiC9vRYELOCra9LKsInXs0St3T6Crp8ZcTawuVcFE3AWWpsCpO-SO-mStae3MluZTgbKXMAmLnGXgMkYntNF7FSndlU0JhUnBXsINNBLEWv5aZ_tJPkDK-Xq1SDGXeeVrds_VZCc74bxQT5R6BAB7lJGiqiLGSCiDwWm4N7Zc_JZCUvtMjMbcIbQHFEcSPVGN7U.0bteS8e5-X7Z9xwseNPde2qSMX-4Kf_rYwtJ2zCm6bM&dib_tag=se&keywords=AWS+%E3%83%8D%E3%83%83%E3%83%88%E3%83%AF%E3%83%BC%E3%82%AF&qid=1733037347&sprefix=aws+%E3%83%8D%E3%83%83%E3%83%88%E3%83%AF%E3%83%BC%E3%82%AF%2Caps%2C196&sr=8-3)で行うEC2/MariaDBを用いたWordPress環境をTerraformで実装。

モジュール管理等は行わず基本的に `main.tf` のみで管理

### [docker-tutorial](https://github.com/Ryuta1346/learn-terraform/tree/main/docker-tutorial)
Terraform の Docker 用チュートリアルより。([Get Started - Docker](https://developer.hashicorp.com/terraform/tutorials/docker-get-started))

### [learn-terraform-aws-instance](https://github.com/Ryuta1346/learn-terraform/tree/main/learn-terraform-aws-instance)
Terraform の AWS 用チュートリアルより。([Get Started - Docker](https://developer.hashicorp.com/terraform/tutorials/docker-get-started))
`outputs.tf` `variables.tf` を用いながらEC2インスタンスの構築と起動まで。

### [learn-terraform-iam-policy](https://github.com/Ryuta1346/learn-terraform/tree/main/learn-terraform-iam-policy)
Terraform のIAMポリシー作成チュートリアル([Create IAM policies](https://developer.hashicorp.com/terraform/tutorials/aws/aws-iam-policy))

### [learn-terraform-lambda-api-gateway](https://github.com/Ryuta1346/learn-terraform/tree/main/learn-terraform-lambda-api-gateway)
AWS Lambda関数とAPIゲートウェイのチュートリアル([Deploy serverless applications with AWS Lambda and API Gateway](https://developer.hashicorp.com/terraform/tutorials/aws/lambda-api-gateway))
