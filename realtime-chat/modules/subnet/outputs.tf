output "subnet_ids" {
  description = "The public subnets for the VPC"
  value       = aws_subnet.subnet[*].id
}