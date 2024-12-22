output "private_elasticache_sg_id" {
  value       = module.private_elasticache_sg.sg_id
  description = "The ID of the private security group"
}

output "private_aurora_sg_id" {
  value       = module.private_aurora_sg.sg_id
  description = "The ID of the private security group"
}

output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "The ID of the Shared Chat VPC"
}

output "vpc_cidr_block" {
  value       = module.vpc.vpc_cidr_block
  description = "The CIDR block of the Shared Chat VPC"
}