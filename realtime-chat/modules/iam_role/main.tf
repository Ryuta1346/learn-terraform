resource "aws_iam_role" "role" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      for stmt in var.assume_role_policy.statement : {
        Effect    = stmt.effect
        Principal = { Service = stmt.principal.service }
        Action    = stmt.action
      }
    ]
  })
}

