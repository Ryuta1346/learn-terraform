resource "aws_iam_role" "role" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = var.assume_role_policy.statement
  })
}

resource "aws_iam_role_policy_attachment" "policy_attachment" {
  for_each   = { for idx, arn in var.policy_arns : idx => arn }
  role       = aws_iam_role.role.name
  policy_arn = each.value
}