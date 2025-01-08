resource "aws_lambda_function" "lambda" {
  function_name = var.lambda_vars.function_name
  runtime       = var.lambda_vars.runtime  # ランタイムを選択
  handler       = var.lambda_vars.handler  # Lambdaのエントリーポイント
  role          = var.iam_role_arn         # Lambda関数に付与するIAMロール
  filename      = var.lambda_vars.filename # アップロードするLambda関数のZIPファイル

  environment {
    variables = {
      ENVIRONMENT = var.environment
    }
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}