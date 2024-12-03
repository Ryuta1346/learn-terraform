output "visitor_chat_vpc_id" {
  value       = aws_vpc.visitor_chat_vpc.id
  description = "The ID of the Visitor's Chat VPC"
}

output "visitor_chat_igw_id" {
  value       = aws_internet_gateway.visitor_chat_igw.id
  description = "The ID of the Visitor's Chat Internet Gateway"
}

output "visitor_chat_public_subnets" {
  value       = aws_subnet.visitor_chat_public_subnet[*].id
  description = "The ID of the Visitor's Chat Public Subnet 1"
}

output "visitor_chat_private_subnets" {
  value       = aws_subnet.visitor_chat_private_subnet[*].id
  description = "The ID of the Visitor's Chat Private Subnet 1"
}