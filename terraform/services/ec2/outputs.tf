# terraform/services/ec2/outputs.tf

output "ec2_public_ip" {
  description = "Adresse IP publique de l'instance EC2."
  value       = aws_instance.web_server.public_ip
}

output "ec2_public_dns" {
  description = "Nom DNS public de l'instance EC2."
  value       = aws_instance.web_server.public_dns
}
