# terraform/services/api-lambda/outputs.tf

output "api_gateway_url" {
  description = "URL de l'API Gateway pour le service Lambda."
  value       = aws_api_gateway_deployment.api_deployment.invoke_url
}
