# terraform/services/api-lambda/main.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configuration du fournisseur AWS
provider "aws" {}

# ------------------------------------------------------------------------------
# Data Source pour l'infrastructure
# ------------------------------------------------------------------------------

data "terraform_remote_state" "infra" {
  backend = "local"  
  config = {
    path = "../../infra/terraform.tfstate"
  }
}

# ------------------------------------------------------------------------------
# Lambda Function
# ------------------------------------------------------------------------------

# Archive du code Lambda
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "lambda_function.py"
  output_path = "lambda_function.zip"
}

# Rôle IAM pour Lambda
resource "aws_iam_role" "lambda_exec" {
  name = "${var.project_name}-lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Politique IAM pour les logs CloudWatch
resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Fonction Lambda
resource "aws_lambda_function" "hello_lambda" {
  function_name    = "${var.project_name}-hello-lambda"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  role             = aws_iam_role.lambda_exec.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.11"
  timeout          = 10
}

# ------------------------------------------------------------------------------
# API Gateway
# ------------------------------------------------------------------------------

# Création de l'API REST
resource "aws_api_gateway_rest_api" "hello_api" {
  name        = "${var.project_name}-hello-api"
  description = "API Gateway pour la fonction Lambda Hello"
}

# Création de la ressource (chemin)
resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.hello_api.id
  parent_id   = aws_api_gateway_rest_api.hello_api.root_resource_id
  path_part   = "hello"
}

# Création de la méthode GET
resource "aws_api_gateway_method" "proxy_method" {
  rest_api_id   = aws_api_gateway_rest_api.hello_api.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "GET"
  authorization = "NONE"
}

# Intégration de la méthode avec la fonction Lambda
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.hello_api.id
  resource_id             = aws_api_gateway_resource.proxy.id
  http_method             = aws_api_gateway_method.proxy_method.http_method
  integration_http_method = "POST" # Lambda est toujours appelé via POST
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.hello_lambda.invoke_arn
}

# Déploiement de l'API
resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda_integration,
    aws_api_gateway_method.proxy_method
  ]

  rest_api_id = aws_api_gateway_rest_api.hello_api.id

  lifecycle {
    create_before_destroy = true
  }
}

# Permission pour API Gateway d'invoquer la fonction Lambda
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  # Source ARN pour restreindre l'invocation à cette API Gateway
  source_arn = "${aws_api_gateway_rest_api.hello_api.execution_arn}/*/*"
}
