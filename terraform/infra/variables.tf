# terraform/infra/variables.tf

variable "aws_region" {
  description = "La région AWS pour le déploiement."
  type        = string
  default     = "eu-west-3" # Région par défaut (Paris)
}

variable "project_name" {
  description = "Nom du projet, utilisé comme préfixe pour les ressources."
  type        = string
  default     = "tf-multi-deploy"
}
