output "alb_sg_id" {
  value       = aws_security_group.alb_sg.id
  description = "The ID of the security group"
}

output "visitor_ecs_sg_id" {
  value       = aws_security_group.visitor_ecs_sg.id
  description = "The ID of the security group"
}