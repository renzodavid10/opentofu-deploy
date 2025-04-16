# Crear la VPC /Lanzar recursos a una RED virtual definida por el usuario
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "mi-vpc-gratis"
  }
}

# Crear una subred pública //Asociamos nuestra sub red Publica con la VPC creada
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-2a" # puedes cambiarlo
  map_public_ip_on_launch = true

  tags = {
    Name = "mi-subred-publica"
  }
}

# Crear una gateway de internet , con esto podremos tener acceso a Internet
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "igw-gratis"
  }
}

# Crear tabla de rutas 
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "tabla-rutas-publica"
  }
}

# Asociar la subred a la tabla de rutas
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.rt.id
}


# Crear grupo de seguridad
resource "aws_security_group" "app" {
  name        = "app-sg"
  description = "Permitir SSH y HTTP"
  vpc_id      = aws_vpc.main.id //Nuestro recurse estara asociado a la VPC

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # ⚠️ Asegúrate de restringir esto luego
  }

  ingress {
    description = "HTTP"
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
    Name = "app-sg"
  }
}
