output "instance_id" {
  description = "ID de la instancia EC2 creada"
  value       = aws_instance.web_server.id
}

output "instance_public_ip" {
  description = "Dirección IP pública de la instancia EC2"
  value       = aws_instance.web_server.public_ip
}

output "instance_private_ip" {
  description = "Dirección IP privada de la instancia EC2"
  value       = aws_instance.web_server.private_ip
}
