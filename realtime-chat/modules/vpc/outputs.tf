output "vpc_id" {
  value       = aws_vpc.vpc.id
  description = "The ID of the Visitor's Chat VPC"
}
output "vpc_cidr_block" {
  value       = aws_vpc.vpc.cidr_block
  description = "The CIDR block for the Visitor's Chat VPC"
}