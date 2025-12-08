# terraform/infra/outputs.tf

output "vpc_id" {
  description = "ID du VPC créé."
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Liste des IDs des sous-réseaux publics."
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Liste des IDs des sous-réseaux privés."
  value       = aws_subnet.private[*].id
}

output "ec2_sg_id" {
  description = "ID du groupe de sécurité pour EC2."
  value       = aws_security_group.ec2_sg.id
}

output "ecs_sg_id" {
  description = "ID du groupe de sécurité pour ECS."
  value       = aws_security_group.ecs_sg.id
}

output "lambda_sg_id" {
  description = "ID du groupe de sécurité pour Lambda."
  value       = aws_security_group.lambda_sg.id
}

output "project_name" {
  description = "Nom du projet."
  value       = var.project_name
}

output "aws_region" {
  description = "Région AWS."
  value       = var.aws_region
}

output "alb_dns_name" {
  description = "Nom DNS de l'Application Load Balancer."
  value       = aws_lb.main.dns_name
}

output "alb_arn" {
  description = "ARN de l'Application Load Balancer."
  value       = aws_lb.main.arn
}

output "tg_ec2_arn" {
  description = "ARN du Target Group pour EC2."
  value       = aws_lb_target_group.ec2.arn
}

output "tg_ecs_arn" {
  description = "ARN du Target Group pour ECS."
  value       = aws_lb_target_group.ecs.arn
}

output "tg_lambda_arn" {
  description = "ARN du Target Group pour Lambda."
  value       = aws_lb_target_group.lambda.arn
}
