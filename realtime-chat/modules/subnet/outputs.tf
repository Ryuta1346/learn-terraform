output "subnet_ids" {
  description = "The public subnets for the VPC"
  value       = [for subnet in aws_subnet.subnet : subnet.id]
}

output "subnet_names" {
  description = "The public subnets for the VPC"
  value       = [for subnet in aws_subnet.subnet : subnet.name]
}