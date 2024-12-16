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