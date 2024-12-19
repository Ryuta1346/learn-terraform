data "aws_iam_policy_document" "policy_document" {
  statement {
    sid       = var.sid
    effect    = var.effect
    actions   = var.actions
    resources = var.resources


    dynamic "condition" {
      for_each = var.condition_vars != null ? [var.condition_vars] : []
      content {
        test     = condition.value.test
        variable = condition.value.variable
        values   = condition.value.values
      }
    }

    principals {
      type        = var.principals_vars.type
      identifiers = var.principals_vars.identifiers
    }
  }
}

resource "aws_iam_policy" "policy" {
  name        = "${var.project_name}-${var.environment}-policy"
  description = var.description
  policy      = data.aws_iam_policy_document.policy_document.json
}