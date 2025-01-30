variable "region" {
  description = "Región de AWS donde se desplegará la infraestructura"
  default     = "us-east-1"
}

variable "availability_zone" {
  description = "Zona de disponibilidad donde se creará la instancia EC2"
  default     = "us-east-1a"
}

variable "ami_id" {
  description = "AMI de Amazon Linux 2 (cambiar según la región)"
  default     = "ami-0c55b159cbfafe1f0"
}

variable "instance_type" {
  description = "Tipo de instancia EC2"
  default     = "t2.micro"
}

variable "key_name" {
  description = "Nombre de la clave SSH en AWS para conectar a la EC2"
  default     = "mi-clave-ssh"
}
