output "visitor_ecs_sg_id" {
  value       = module.private_sg.sg_id
  description = "The ID of the security group"
}