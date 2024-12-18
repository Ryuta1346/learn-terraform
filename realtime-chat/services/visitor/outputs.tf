output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "The ID of the Visitor's Chat VPC"
}

output "vpc_cidr_block" {
  value       = module.vpc.vpc_cidr_block
  description = "The CIDR block of the Visitor's Chat VPC"
}

output "ecs_route_table_id" {
  value       = module.private_ecs_route_table.route_table_id
  description = "The ID of the private route table"
}

output "ecs_chat_sg_id" {
  value       = module.private_ecs_chat_sg.sg_id
  description = "The ID of the private security group"
}