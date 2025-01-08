output "ecs_cluster" {
  value       = aws_ecs_cluster.cluster[*].name
  description = "The name of the Visitor's Chat ECS Clusters"
}