// terraform state rm 'module.backup'でterraform管理から除外
# module "backup" {
#   source = "./common"
# }
data "aws_ssm_parameter" "aws_account_id" {
  name = "/terraform/aws/account-id"
}

data "aws_ssm_parameter" "github_owner" {
  name = "/terraform/github/owner"
}

variable "terraform_github_actions_role_name" {
  description = "作成するIAMロールの名前"
  type        = string
  default     = "GitHubActionsRole"
}

variable "github_repo" {
  description = "GitHubリポジトリ名"
  type        = string
  default     = "learn-terraform"
}

resource "aws_iam_role" "github_actions_role" {
  name = var.terraform_github_actions_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_ssm_parameter.aws_account_id.value}:oidc-provider/token.actions.githubusercontent.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${data.aws_ssm_parameter.github_owner.value}/${var.github_repo}:ref:*"
          }
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "full_access_policy" {
  name        = "${var.terraform_github_actions_role_name}_full_access_policy"
  description = "Full access to all resources and actions"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "*",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_full_access_policy" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = aws_iam_policy.full_access_policy.arn
}