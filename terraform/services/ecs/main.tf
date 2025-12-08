# terraform/services/ecs/main.tf

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
# ECR (Elastic Container Registry)
# ------------------------------------------------------------------------------

resource "aws_ecr_repository" "hello_ecs" {
  name                 = "${var.project_name}/hello-ecs"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# ------------------------------------------------------------------------------
# ECS Cluster
# ------------------------------------------------------------------------------

resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"
}

# ------------------------------------------------------------------------------
# IAM Roles
# ------------------------------------------------------------------------------

# Rôle pour l'exécution de la tâche ECS (Fargate)
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.project_name}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ------------------------------------------------------------------------------
# ECS Task Definition
# ------------------------------------------------------------------------------

resource "aws_ecs_task_definition" "hello_ecs" {
  family                   = "${var.project_name}-hello-ecs"
  cpu                      = 256
  memory                   = 512
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "hello-ecs-container"
      image     = "${aws_ecr_repository.hello_ecs.repository_url}:latest"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.project_name}-hello-ecs"
          "awslogs-region"        = data.terraform_remote_state.infra.outputs.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

# ------------------------------------------------------------------------------
# CloudWatch Log Group
# ------------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "hello_ecs" {
  name              = "/ecs/${var.project_name}-hello-ecs"
  retention_in_days = 7
}

# ------------------------------------------------------------------------------
# ECS Service
# ------------------------------------------------------------------------------

resource "aws_ecs_service" "hello_ecs" {
  name            = "${var.project_name}-hello-ecs-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.hello_ecs.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.terraform_remote_state.infra.outputs.private_subnet_ids # Utiliser les sous-réseaux privés
    security_groups  = [data.terraform_remote_state.infra.outputs.ecs_sg_id]
    assign_public_ip = false # Pas besoin d'IP publique derrière un ALB
  }

  load_balancer {
    target_group_arn = data.terraform_remote_state.infra.outputs.tg_ecs_arn
    container_name   = "hello-ecs-container"
    container_port   = 80
  }

  depends_on = [
    aws_cloudwatch_log_group.hello_ecs
  ]
}
