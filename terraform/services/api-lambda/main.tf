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
  backend = "local" # Simuler le backend pour la démo
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

  # Ajouter la politique pour l'invocation par l'ALB
  inline_policy {
    name = "alb_invoke_policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Action   = "lambda:InvokeFunction"
        Effect   = "Allow"
        Resource = aws_lambda_function.hello_lambda.arn
      }]
    })
  }
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
# ALB Integration
# ------------------------------------------------------------------------------

# Enregistrement de la fonction Lambda dans le Target Group
resource "aws_lb_target_group_attachment" "lambda_tg_attachment" {
  target_group_arn = data.terraform_remote_state.infra.outputs.tg_lambda_arn
  target_id        = aws_lambda_function.hello_lambda.arn
}

# Permission pour l'ALB d'invoquer la fonction Lambda
resource "aws_lambda_permission" "alb_lambda" {
  statement_id  = "AllowALBInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello_lambda.function_name
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = data.terraform_remote_state.infra.outputs.alb_arn
}
