# BtoC領域におけるリアルタイムなチャットシステムの構築

## 概要
企業担当者とユーザー間でのリアルタイムなチャットシステムの構築を前提にしたインフラ環境の構築プロジェクトを想定。

## 構成
```md
/backup
/envs ## 環境ごとのリソース作成
    /dev
        - backend.tf
        - main.tf
        - variables.tf
        - terraform.tfvars
    /prod
    /stg
/modules
    /ecs ## 各リソースごとの定義
    /elb
    /iam_policy
/services ## プロダクトレベルでのサービスごとのリソース定義
    /aws_resources  ## 特定のVPCに属さないAWSリソース群
        - sqs_queue.tf
        - variables.tf
        - outputs.tf
    /company
        - main.tf
        - outputs.tf
        - variables.tf
    /shared
        - main.tf
        - outputs.tf
        - variables.tf
    /shared_company_deps ## 共通用サービス(/shared)と企業用サービス群の依存関係あるリソース定義
        - aurora.tf
        - elasticache.tf
        - variables.tf
        - vpc_peering.tf
    /shared_visitor_deps
        - aurora.tf
        - elasticache.tf
        - variables.tf
        - vpc_peering.tf
    /visitor
        - main.tf
        - outputs.tf
        - variables.tf
```

### envs: 環境ごとのリソース作成用
開発環境、ステージング環境、プロダクション環境ごとに分けてリソース管理する。

リソース作成時は、作成したい環境ごとにワーキングディレクトリを指定してコマンド実行->リソース作成を行う。

環境ごとに異なる固定値の指定などはこのレベルで行う

### modules: リソースごとの共通管理用モジュール
`s3` `ECS` などTerraform内で使用するリソース群を、再利用性や標準化のためにモジュール化して定義・利用する

共通化したものを利用することで実装ごとの思わぬ差分等を生まないようにする。

### services: サービスごとの管理用モジュール
サービス単位でのインフラ管理用。

ある程度のサイズのあるインフラ構成になる場合に`/dev`でまとめて定義すると保守性・可読性に問題が起きえるため、アプリケーションレイヤーのサービス単位で管理する。

各サービスで依存がある場合、依存管理用のモジュールを切って定義する等も検討(e.g: `/shared_company_deps` )

このレベルでは1つの `main.tf` で管理するより、AWSリソース単位で定義するほうが管理しやすいため、`aurora.tf`などAWSリソース単位で定義・利用する。