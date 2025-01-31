provider "aws" {
  region = var.region
}

variable "vpc_id" {
  default = "vpc-0cec5cb97f2fc50b6"
}

data "aws_vpc" "default" {
  id = var.vpc_id
}

data "aws_subnet" "default" {
  vpc_id            = var.vpc_id
  availability_zone = var.availability_zone
}

data "aws_security_groups" "existing_sg" {
  filter {
    name   = "group-name"
    values = ["ec2-security-group"]
  }
}

resource "aws_security_group" "ec2_sg" {
  count       = length(data.aws_security_groups.existing_sg.ids) > 0 ? 0 : 1
  name_prefix = "ec2-security-group-"  
  description = "Permitir SSH y HTTP"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-security-group"
  }
}

locals {
  security_group_id = length(data.aws_security_groups.existing_sg.ids) > 0 ? data.aws_security_groups.existing_sg.ids[0] : aws_security_group.ec2_sg[0].id
}

resource "tls_private_key" "generated" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "mi-clave-ssh"
  public_key = tls_private_key.generated.public_key_openssh
}

resource "aws_instance" "web_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnet.default.id
  vpc_security_group_ids = [local.security_group_id]
  key_name               = aws_key_pair.generated_key.key_name  

  tags = {
    Name = "web-server"
  }
}
