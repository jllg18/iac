output "instance_public_ip" {
  description = "Dirección IP pública de la instancia EC2"
  value       = aws_instance.web_server.public_ip
}

output "instance_id" {
  description = "ID de la instancia EC2"
  value       = aws_instance.web_server.id
}

output "security_group_id" {
  description = "ID del Security Group asignado"
  value       = local.security_group_id
}
