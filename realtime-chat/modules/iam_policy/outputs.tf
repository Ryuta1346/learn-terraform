output "policy_json" {
  description = "The JSON representation of the policy"
  value       = data.aws_iam_policy_document.policy.json
}

output "policy_arn" {
  description = "The ARN of the policy"
  value       = data.aws_iam_policy_document.policy.arn
}