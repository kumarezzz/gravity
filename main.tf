terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    Name = "igw"
  }
}

resource "aws_subnet" "pub-subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "pub-Subnet-1"
  }
}

resource "aws_route_table" "pub-rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "pub-rt-1"
  }
}

resource "aws_route_table_association" "pub-a" {
  subnet_id      = aws_subnet.pub-subnet.id
  route_table_id = aws_route_table.pub-rt.id
}

resource "tls_private_key" "rsa-4096" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

variable "key_name" {
  default = "my-key-pair"
}

resource "aws_key_pair" "key_pair" {
  key_name   = var.key_name
  public_key = tls_private_key.rsa-4096.public_key_openssh
}

resource "local_file" "private-key" {
  filename = "${var.key_name}.pem"
  content  = tls_private_key.rsa-4096.private_key_pem
}

resource "aws_instance" "ec2" {
  ami                         = "ami-0a0e5d9c7acc336f1"
  instance_type               = "t2.medium"
  subnet_id                   = aws_subnet.pub-subnet.id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.key_pair.key_name

  tags = {
    Name = "web-server"
  }

  user_data = file("scripts.sh")

  vpc_security_group_ids = [
    aws_security_group.allow_ssh.id,
    aws_security_group.allow_tls.id
  ]
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
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
    Name = "allow_tls"
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
    description = "ssh"
    from_port   = 8090
    to_port     = 8090
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
    Name = "allow_ssh"
  }
}

resource "aws_subnet" "pri-subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "pri-subnet"
  }
}

resource "aws_eip" "eip" {
  vpc = true
}

resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.pub-subnet.id

  tags = {
    Name = "gw NAT"
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "pri-rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.natgw.id
  }

  tags = {
    Name = "pri-rt-1"
  }
}

resource "aws_route_table_association" "pri-a" {
  subnet_id      = aws_subnet.pri-subnet.id
  route_table_id = aws_route_table.pri-rt.id
}
