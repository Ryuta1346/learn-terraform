# モジュール概要

このモジュールは、Terraformを使用してインフラストラクチャを管理するための基本的な設定を提供するもの。

この実装で作成したリソースを用いて、CIを使ってTerraformの各種コマンドを実行する。

## 管理用リソースついて
1. IAMロール（aws_iam_role）:
GitHub ActionsからAWSリソースにアクセスするためのIAMロールを作成。

2. IAMポリシー（aws_iam_policy）:
全てのAWSリソースにフルアクセス権を持つIAMポリシーを作成。

3. IAMロールへのポリシーアタッチメント（aws_iam_role_policy_attachment）:
作成したIAMロールに、上記のIAMポリシーを関連付け。

4. データソース（aws_ssm_parameter）:
SSM Parameter StoreからAWSアカウントIDおよびGitHubリポジトリオーナーを取得。
先んじてAWSコンソールまたはCLIから作成しておく

## IAMロールの作成
GitHub ActionsからAWSリソースにアクセスするためのIAMロール。
このロールはではGitHub ActionsのOIDCプロバイダを信頼し、特定のリポジトリからのみ引き受け可能する。

### AWSでやるべきこと
1. OIDCプロバイダの設定
- AWSの `IAM` -> `IDプロバイダ` から「プロバイダを追加」を押下し、以下を設定
    1. プロバイダのタイプ: `OpenID Connect`
    2. プロバイダの URL: `https://token.actions.githubusercontent.com`
    3. 対象者: `sts.amazonaws.com`

2. SSM Parameter Storeの設定
- AWSアカウントとGitHubリポジトリオーナーを設定

### GitHubでやるべきこと
1. Secretesにこのプロジェクトで作成したIAM_ROLEのARNを設定
    - `AWS_IAM_ROLE_TO_ASSUME`

## IAMポリシーの作成
Terraformでのリソース作成・更新・削除などを行う権限を持たせたIAMポリシーを作成する。

今回は利便性のためフルアクセスを許可しているが、本番等では権限を任意のリソースに絞って設定する。

###  IAMロールへのポリシーアタッチメント
作成したIAMロールとIAMポリシーを関連づける。これにより、IAMロールが指定された権限を行使できるようになる。

## CI実行までの手順
1. OIDCプロバイダの作成
2. SSMパラメータの登録
3. 手動でのリソース作成(ここまでは手動で`terraform apply`まで行う)
4. GitHubのSecretesに作成したIAM ROLEのARNを登録する
5. GitHub Actionsのワークフローの設定
    - `terraform plan` や `terraform apply`などを実行する用のCIの作成
6. GitHubのActionsから、今回作成したCIを選択し、実行する
    - 今回のプロジェクトでは、手動で実行するディレクトリの指定とapplyの実行有無までを設定して実行する
    - 場合によってPR作成時に `terraform plan` を実行しコメント上に表示したり、`main` へのマージで`terraform apply`を実行させるなどカスタムする

## Terraform stateのS3管理について

`module/common/backend_setup.tf`で、terraformのstateファイルを管理するリソースを作成する。

その後、`backend.tf`に`backend`を追加し、作成したリソースの情報を追記することで、今後のstateファイルがS3上で管理されるようになる。

ただし、作成した管理用S3情報をそのままにしておくと`terraform destroy`等を実行した場合に削除されてしまう可能性がある。

削除不可の設定にしている場合は削除不可のエラーメッセージが表示されたり、本来管理したいリソース以外の情報を残し続けておくことになる。

そこで、state管理用のS3リソースの作成をstate管理上削除しておくことで呼び出しコードの削除や`terraform destroy`の影響を受けないようにできる

```bash
# stateファイルの中身を確認
$ terraform state list

# state管理用のリソース情報を削除
$ terraform state rm "対象のモジュール名"
```