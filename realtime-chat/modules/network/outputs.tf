output "vpc_id" {
  value       = aws_vpc.vpc.id
  description = "The ID of the Visitor's Chat VPC"
}

output "igw_id" {
  value       = aws_internet_gateway.igw.id
  description = "The ID of the Visitor's Chat Internet Gateway"
}

output "public_subnets" {
  value       = aws_subnet.public_subnet[*].id
  description = "The ID of the Visitor's Chat Public Subnet 1"
}

output "private_subnets" {
  value       = aws_subnet.private_subnet[*].id
  description = "The ID of the Visitor's Chat Private Subnet 1"
}