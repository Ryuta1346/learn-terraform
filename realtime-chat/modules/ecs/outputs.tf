output "ecs_cluster" {
  value       = aws_ecs_cluster.chat.name
  description = "The name of the Visitor's Chat ECS Cluster"
}