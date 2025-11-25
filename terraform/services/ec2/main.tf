# terraform/services/ec2/main.tf

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
# EC2 Instance
# ------------------------------------------------------------------------------

# Trouver l'AMI la plus récente d'Amazon Linux 2
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Script utilisateur pour installer un serveur web simple et afficher le message
locals {
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>hello from ec2</h1>" > /var/www/html/index.html
  EOF
}

resource "aws_instance" "web_server" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  subnet_id              = data.terraform_remote_state.infra.outputs.public_subnet_ids[0]
  vpc_security_group_ids = [data.terraform_remote_state.infra.outputs.ec2_sg_id]
  user_data              = local.user_data
  associate_public_ip_address = true

  tags = {
    Name = "${var.project_name}-ec2-web-server"
  }
}
