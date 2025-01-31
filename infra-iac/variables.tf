variable "region" {
  default = "us-east-1"
}

variable "availability_zone" {
  default = "us-east-1a"
}

variable "ami_id" {
  default = "ami-06fcf170f013de4e2"  # Reemplaza con la AMI de tu preferencia
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  default = "mi-clave-ssh"  # Nombre de la clave SSH generada
}
