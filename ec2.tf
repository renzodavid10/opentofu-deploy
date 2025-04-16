# variables

variable "instance_name" {
  description = "Name of instance"
  type        = string
  default     = "Primera Instancia"
}

variable "instance_type" {
  description = "Type of instance"
  type        = string
  default     = "t2.micro"
}
variable "instance_bootstrap_script" {
  description = "Instance bootstrap script"
  type        = string
  default     = "ec2.sh"

}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  # Asegúrate de que la subred y el grupo de seguridad estén configurados correctamente
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.app.id]

  user_data = file("${path.module}/bootstrap/${var.instance_bootstrap_script}")

  tags = {
    Name = var.instance_name
  }

  depends_on = [aws_security_group.app, aws_subnet.public]
}


#Outputs
output "aws_security_group" {
  value = aws_security_group.app.id
}
output "aws_instance" {
  value = aws_instance.web.public_ip
}
output "aws_vpc" {
  value = aws_vpc.main.id
}
