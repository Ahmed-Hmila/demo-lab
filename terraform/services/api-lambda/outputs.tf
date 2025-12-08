# terraform/services/api-lambda/outputs.tf

output "lambda_function_name" {
  description = "Nom de la fonction Lambda."
  value       = aws_lambda_function.hello_lambda.function_name
}
