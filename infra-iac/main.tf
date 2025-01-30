provider "aws" {
  region = var.region
}

# Obtener la VPC por defecto
data "aws_vpc" "default" {
  default = true
}

# Obtener la subred pública dentro de la VPC por defecto
data "aws_subnet" "default" {
  vpc_id = data.aws_vpc.default.id
  availability_zone = var.availability_zone
}

# Crear un grupo de seguridad para permitir SSH y HTTP
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-security-group"
  description = "Permitir SSH y HTTP"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Acceso SSH desde cualquier parte (mejor restringir en producción)
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Permitir tráfico HTTP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Permitir salida a cualquier destino
  }

  tags = {
    Name = "ec2-security-group"
  }
}

# Crear una instancia EC2
resource "aws_instance" "web_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnet.default.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name               = var.key_name

  tags = {
    Name = "web-server"
  }
}
