variable "region" {
  default = "us-east-1"
}

variable "availability_zone" {
  default = "us-east-1a"
}

variable "ami_id" {
  default = "ami-0c55b159cbfafe1f0"  # AMI de Amazon Linux 2 (ejemplo, verificar en AWS)
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  default = "mi-clave-ssh"  # Nombre de la clave SSH en AWS
}
