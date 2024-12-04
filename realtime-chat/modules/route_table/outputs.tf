output "vpc_id" {
  value       = aws_vpc.vpc.id
  description = "The ID of the Visitor's Chat VPC"
}