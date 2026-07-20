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

# --- 1. Variables & Locals ---
variable "project" { default = "projet-web" }
variable "env" { default = "dev" }

locals {
  prefix = "${var.project}-${var.env}"
  tags = {
    Project = var.project
    Env     = var.env
  }
}

# --- 2. Réseau (VPC) ---
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags                 = merge(local.tags, { Name = "${local.prefix}-vpc" })
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags   = local.tags
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags                    = merge(local.tags, { Name = "${local.prefix}-subnet" })
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = local.tags
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.rt.id
}

# --- 3. Sécurité (Firewall) ---
resource "aws_security_group" "web_sg" {
  name   = "${local.prefix}-sg"
  vpc_id = aws_vpc.main.id

  # SSH (Port 22)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP (Port 80)
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
}

# --- 4. Serveurs (Instances) ---
# Image Amazon Linux 2 (plus stable pour les labs)
data "aws_ssm_parameter" "linux_ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# Clé du labo (vockey)
data "aws_key_pair" "lab_key" {
  key_name           = "vockey"
  include_public_key = true
}

resource "aws_instance" "web" {
  count                  = 2
  ami                    = nonsensitive(data.aws_ssm_parameter.linux_ami.value)
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = data.aws_key_pair.lab_key.key_name

  tags = merge(local.tags, { Name = "${local.prefix}-server-${count.index + 1}" })
}

# --- 5. Génération Inventaire Ansible ---
resource "local_file" "inventory" {
  content = <<EOT
[web_servers]
${aws_instance.web[0].public_ip} ansible_user=ec2-user ansible_ssh_private_key_file=./labsuser.pem
${aws_instance.web[1].public_ip} ansible_user=ec2-user ansible_ssh_private_key_file=./labsuser.pem
EOT
  filename = "inventory.ini"
}
