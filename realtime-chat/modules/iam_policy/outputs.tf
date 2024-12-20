output "policy_json" {
  description = "The JSON representation of the policy"
  value       = data.aws_iam_policy_document.policy_document.json
}

output "policy_arn" {
  description = "The ARN of the policy"
  value       = aws_iam_policy.policy.arn
}