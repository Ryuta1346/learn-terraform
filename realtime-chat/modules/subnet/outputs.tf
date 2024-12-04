output "public_subnets" {
  description = "The public subnets for the VPC"
  value       = aws_subnet.public_subnet[*].id
}

output "private_subnets" {
  description = "The private subnets for the VPC"
  value       = aws_subnet.private_subnet[*].id
}