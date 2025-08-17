#VPC
resource "aws_vpc" "lab-vpc" {
  cidr_block = "10.0.0.0/16" 
  enable_dns_hostnames = true
  enable_dns_support =  true
  tags = {
    Name = "lab-vpc"
  }
}

#SUBNET PUBLICA A
resource "aws_subnet" "lab-subnet-public1" {
  vpc_id     = aws_vpc.lab-vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a" # Zona de disponibilidad
  map_public_ip_on_launch = true # Habilita el lanzamiento con IP pública
  tags = {
    Name = "lab-subnet-public1-us-east-1a"
  }
}

#SUBNET PRIVADA A
resource "aws_subnet" "lab-subnet-private1" {
  vpc_id     = aws_vpc.lab-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a" # Zona de disponibilidad

  tags = {
    Name = "lab-subnet-private1-us-east-1a"
  }
}

#SUBNET PUBLICA B
resource "aws_subnet" "lab-subnet-public2" {
  vpc_id     = aws_vpc.lab-vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b" # Zona de disponibilidad
  map_public_ip_on_launch = true # Habilita el lanzamiento con IP pública
  tags = {
    Name = "lab-subnet-public2"
  }
}

#SUBNET PRIVADA B
resource "aws_subnet" "lab-subnet-private2" {
  vpc_id     = aws_vpc.lab-vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1b" # Zona de disponibilidad

  tags = {
    Name = "lab-subnet-private2"
  }
}

#TABLA DE RUTEO PUBLICA
resource "aws_route_table" "public-rtb" {
  vpc_id = aws_vpc.lab-vpc.id

  tags = {
    Name = "lab-rtb-public"
  }
}

#TABLA DE RUTEO PRIVADA
resource "aws_route_table" "private-rtb" {
  vpc_id = aws_vpc.lab-vpc.id

  tags = {
    Name = "lab-rtb-private1-us-east-1a"
  }
}

#ROUTE TABLE ASSOCIATION PUBLICA
resource "aws_route_table_association" "lab_rtb_assoc" {
  for_each = {
    subnet1 = aws_subnet.lab-subnet-public1.id
    subnet2 = aws_subnet.lab-subnet-public2.id
  }
  subnet_id = each.value
  route_table_id = aws_route_table.public-rtb.id
}

#ROUTE TABLE ASSOCIATION PRIVADA
resource "aws_route_table_association" "lab_private_rtb_assoc" {
  for_each = {
    subnet1 = aws_subnet.lab-subnet-private1.id
    subnet2 = aws_subnet.lab-subnet-private2.id
  }
  subnet_id = each.value
  route_table_id = aws_route_table.private-rtb.id
}

#NAT GATEWAY
resource "aws_nat_gateway" "lab_nat" {
  allocation_id = aws_eip.lab-nat-eip.id
  subnet_id     = aws_subnet.lab-subnet-public1.id

  tags = {
    Name = "lab-nat-public1-us-east-1a"
  }
  depends_on = [aws_internet_gateway.lab-igw]
}

#Elastic IP para NAT
resource "aws_eip" "lab-nat-eip" {
  domain = "vpc"
  tags = {
    Name = "lab-nat-eip"
  }
}

#INTERNET GATEWAY
resource "aws_internet_gateway" "lab-igw" {
  vpc_id = aws_vpc.lab-vpc.id
  tags = {
   Name = "lab-igw"
  }
}

resource "aws_route" "route_internet_gateway" {
  route_table_id = aws_route_table.public-rtb.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.lab-igw.id  
}

resource "aws_route" "route_intenet_gateway" {
  route_table_id = aws_route_table.private-rtb.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_nat_gateway.lab_nat.id
}

#SECURITY GROUP
resource "aws_security_group" "web-security-group" {
  name        = "Web Security Group"
  description = "Enable HTTP access"
  vpc_id      = aws_vpc.lab-vpc.id
    tags = {
        Name = "Web Security Group"
      }
}

#REGLA DE INGRESO
resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.web-security-group.id
  description = "Permit web requests"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

# REGLA DE EGRESO
resource "aws_vpc_security_group_egress_rule" "allow_all" {
  security_group_id = aws_security_group.web-security-group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # todos los protocolos
}


#EC2

resource "aws_instance" "web_server1" {
    ami = data.aws_ami.amazon_linux.id
    instance_type = "t2.micro"
    key_name = "vockey"
    associate_public_ip_address = true
    subnet_id = aws_subnet.lab-subnet-public2.id
    vpc_security_group_ids = [aws_security_group.web-security-group.id]
    
    user_data = <<-EOF
                #!/bin/bash
                # Install Apache Web Server and PHP
                dnf install -y httpd wget php mariadb105-server
                # Download Lab files
                wget https://aws-tc-largeobjects.s3.us-west-2.amazonaws.com/CUR-TF-100-ACCLFO-2/2-lab2-vpc/s3/lab-app.zip
                unzip lab-app.zip -d /var/www/html/
                # Turn on web server
                chkconfig httpd on
                service httpd start
                EOF
      tags = {
        Name = "Web Server 1"
      }
}

# Buscar la última AMI de Amazon Linux 2 en tu región
data "aws_ami" "amazon_linux" {
  most_recent = true
  filter {
    name   = "name"
    values = ["al2023-ami-2023.8.20250808.1-kernel-6.1-x86_64"]
  }
  owners = ["137112412989"] # Cuenta oficial de Amazon Linux
}