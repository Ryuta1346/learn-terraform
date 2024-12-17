output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "The ID of the Visitor's Chat VPC"
}

output "private_ecs_route_table_id" {
  value       = module.private_ecs_route_table.route_table_id
  description = "The ID of the private route table"
}