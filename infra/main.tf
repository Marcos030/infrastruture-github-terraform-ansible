provider "aws" {
  region = var.region
}

# 1. VPC e Network
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags       = { Name = "vpc-automation-git-terraform-ansible" }
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

# 2. Security Group
resource "aws_security_group" "sg_automation" {
  name        = "sg_automation"
  description = "Allow SSH and App port"
  vpc_id      = aws_vpc.main.id
}

# Regras separadas (obrigatório no AWS Provider v5+)
resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.sg_automation.id
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "app" {
  security_group_id = aws_security_group.sg_automation.id
  from_port         = 8081
  to_port           = 8081
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.sg_automation.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# 3. Instância EC2
resource "aws_instance" "vm" {
  ami           = "ami-0c7217cdde317cfec"
  instance_type = "t3.micro"

  subnet_id                   = aws_subnet.subnet.id
  vpc_security_group_ids      = [aws_security_group.sg_automation.id]
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    echo "ubuntu:${var.admin_password}" | chpasswd
    sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
    systemctl restart sshd
  EOF

  tags = { Name = "vm-automation-git-terraform-ansible" }
}
