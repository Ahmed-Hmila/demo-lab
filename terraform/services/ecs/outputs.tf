# terraform/services/ecs/outputs.tf

output "ecr_repository_url" {
  description = "URL du dépôt ECR."
  value       = aws_ecr_repository.hello_ecs.repository_url
}

output "ecs_cluster_name" {
  description = "Nom du cluster ECS."
  value       = aws_ecs_cluster.main.name
}

# Note: L'IP publique de l'instance Fargate est dynamique et difficile à obtenir directement
# via Terraform sans un Load Balancer. Pour la démo, on se contentera du nom du cluster et du service.
# Si un Load Balancer était requis, il faudrait l'ajouter dans le module infra ou ici.
output "ecs_service_name" {
  description = "Nom du service ECS."
  value       = aws_ecs_service.hello_ecs.name
}
