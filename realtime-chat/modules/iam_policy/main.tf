# data "aws_iam_policy_document" "visitor_chat_queue_policy" {
#   statement {
#     sid       = "AllowVPCEndpointAccess" // 管理用に設定
#     effect    = "Allow"
#     actions   = ["sqs:SendMessage"]
#     resources = [aws_sqs_queue.visitor_chat_queue.arn]

#     condition {
#       test     = "ArnEquals"
#       variable = "aws:SourceArn"
#       values   = [module.sqs_chat_vpc_endpoint.vpc_endpoint_arn]
#     }
#     principals {
#       type        = "AWS"
#       identifiers = ["*"]
#     }
#   }
# }

data "aws_iam_policy_document" "policy" {
  statement {
    sid       = var.sid
    effect    = var.effect
    actions   = var.actions
    resources = var.resources

    condition {
      test     = var.condition_vars.test
      variable = var.condition_vars.variable
      values   = var.condition_vars.values
    }

    principals {
      type        = var.principals_vars.type
      identifiers = var.principals_vars.identifiers
    }
  }
}