output "vpc_endpoint_arn" {
  description = "The ARN of the VPC endpoint"
  value       = aws_vpc_endpoint.endpoint.arn
}