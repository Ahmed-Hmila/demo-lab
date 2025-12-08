# terraform/services/ecs/outputs.tf

output "ecr_repository_url" {
  description = "URL du dépôt ECR."
  value       = aws_ecr_repository.hello_ecs.repository_url
}

output "ecs_cluster_name" {
  description = "Nom du cluster ECS."
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "Nom du service ECS."
  value       = aws_ecs_service.hello_ecs.name
}
