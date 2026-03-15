# main.tf
provider "aws" {
  region = var.region
}

# 1. VPC e Network
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "vpc-automation" }
}

resource "aws_subnet" "subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.rt.id
}

# 2. Security Group (Equivalente ao NSG)
resource "aws_security_group" "sg_automation" {
  name        = "sg_automation"
  description = "Allow SSH and App port"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 3. Instância EC2
resource "aws_instance" "vm" {
  ami           = "ami-0c7217cdde317cfec" # Verifique se esta AMI Ubuntu é válida na sua região
  instance_type = "t3.micro"            # t3.micro é geralmente a opção Free Tier atual
  
  subnet_id                   = aws_subnet.subnet.id
  vpc_security_group_ids      = [aws_security_group.sg_automation.id]
  associate_public_ip_address = true

  # CONFIGURAÇÃO PARA ANSIBLE COM SENHA (IGUAL AO LAB AZURE)
  user_data = <<-EOF
              #!/bin/bash
              echo "ubuntu:${var.admin_password}" | chpasswd
              sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
              systemctl restart sshd
              EOF

  tags = { Name = "vm-automation-git-terraform-ansible" }
}