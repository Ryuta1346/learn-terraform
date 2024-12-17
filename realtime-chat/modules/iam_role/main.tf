resource "aws_iam_role" "role" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = var.assume_role_policy.statement
  })
}

resource "aws_iam_role_policy_attachment" "policy_attachment" {
  role       = aws_iam_role.role.name
  for_each   = { for arn in var.policy_arns : arn => arn }
  policy_arn = each.value
}