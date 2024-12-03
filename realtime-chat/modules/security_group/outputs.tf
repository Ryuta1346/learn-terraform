output "visitor_chat_alb_sg_id" {
  value       = aws_security_group.visitor_chat_alb_sg.id
  description = "The ID of the security group"
}