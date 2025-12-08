# terraform/services/ec2/outputs.tf

output "ec2_instance_id" {
  description = "ID de l'instance EC2."
  value       = aws_instance.web_server.id
}
