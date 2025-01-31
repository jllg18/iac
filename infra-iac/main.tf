provider "aws" {
  region = var.region
}

# Variable para la VPC específica
variable "vpc_id" {
  default = "vpc-0cec5cb97f2fc50b6"  # ID de la VPC de la imagen
}

# Obtener la VPC específica
data "aws_vpc" "default" {
  id = var.vpc_id
}

# Obtener la subred pública dentro de la VPC específica
data "aws_subnet" "default" {
  vpc_id = var.vpc_id
  availability_zone = var.availability_zone
}

# Buscar si ya existe un Security Group con el nombre "ec2-security-group"
data "aws_security_groups" "existing_sg" {
  filter {
    name   = "group-name"
    values = ["ec2-security-group"]
  }
}

# Crear un Security Group si no existe
resource "aws_security_group" "ec2_sg" {
  count       = length(data.aws_security_groups.existing_sg.ids) > 0 ? 0 : 1
  name_prefix = "ec2-security-group-"  # Prefijo para evitar duplicados
  description = "Permitir SSH y HTTP"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Acceso SSH desde cualquier parte (ajustar en producción)
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Permitir tráfico HTTP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Permitir salida a cualquier destino
  }

  tags = {
    Name = "ec2-security-group"
  }
}

# Obtener el ID del Security Group existente o el que creó Terraform
locals {
  security_group_id = length(data.aws_security_groups.existing_sg.ids) > 0 ? data.aws_security_groups.existing_sg.ids[0] : aws_security_group.ec2_sg[0].id
}

# Crear una instancia EC2
resource "aws_instance" "web_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnet.default.id
  vpc_security_group_ids = [local.security_group_id]  # Usa el SG existente o el nuevo
  key_name               = var.key_name

  tags = {
    Name = "web-server"
  }
}
