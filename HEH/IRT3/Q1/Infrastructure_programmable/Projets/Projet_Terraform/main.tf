# C'est ici qu'on crée les ressources AWS avec Terraform

#####################
# Terraform provider 
#####################
# un provider est un plugin qui permet à Terraform d'interagir avec une API spécifique (ici AWS)
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configuration du provider AWS
provider "aws" {
  region = var.region
}


#####################
# VPC
#####################
# Create a VPC
# resource block définit une ressource cloud à créer
resource "aws_vpc" "main_vpc" {
  cidr_block           = var.subnet_cidr_vpc
  enable_dns_hostnames = var.dns_hostnames

  tags = {
    Name = "VPC principal"
  }
}

# table de routage pour les subnets publics
resource "aws_route_table" "internet_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = var.all_destination_cidr
    gateway_id = aws_internet_gateway.gw.id
  }

# tags c'est pour nommer la ressource dans AWS
  tags = {
    Name = "Internet Route Table"
  }
}

# association de la table de routage avec les subnets publics
resource "aws_route_table_association" "public_subnet1" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.internet_route_table.id
}

resource "aws_route_table_association" "public_subnet2" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.internet_route_table.id
}


# table de routage pour les subnets privés avec NAT Gateway
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block     = var.all_destination_cidr
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "Private Route Table with nat gateway"
  }
}

# association de la table de routage avec les subnets privés
resource "aws_route_table_association" "private_subnet1" {
  subnet_id      = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_subnet2" {
  subnet_id      = aws_subnet.private_subnet2.id
  route_table_id = aws_route_table.private_route_table.id
}


#####################
# SUBNETS
#####################
# PUBLIC SUBNET
# Public subnet 1
resource "aws_subnet" "public_subnet1" {
  cidr_block              = var.public_subnet_cidr[0]
  vpc_id                  = aws_vpc.main_vpc.id
  map_public_ip_on_launch = var.map_public_ip_on_launch
  availability_zone       = var.availability_zones[0]

  tags = {
    Name = "Public Subnet 1"
  }
}

# Public subnet 2
resource "aws_subnet" "public_subnet2" {
  cidr_block              = var.public_subnet_cidr[1]
  vpc_id                  = aws_vpc.main_vpc.id
  map_public_ip_on_launch = var.map_public_ip_on_launch
  availability_zone       = var.availability_zones[1]

  tags = {
    Name = "Public Subnet 2"
  }
}

# PRIVATE SUBNET
# Private subnet 1
resource "aws_subnet" "private_subnet1" {
  cidr_block        = var.private_subnet_cidr[0]
  vpc_id            = aws_vpc.main_vpc.id
  availability_zone = var.availability_zones[0]

  tags = {
    Name = "Private Subnet 1"
  }
}

# Private subnet 2
resource "aws_subnet" "private_subnet2" {
  cidr_block        = var.private_subnet_cidr[1]
  vpc_id            = aws_vpc.main_vpc.id
  availability_zone = var.availability_zones[1]

  tags = {
    Name = "Private Subnet 2"
  }
}


#####################
# INTERNET GATEWAY
#####################
# Create an Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main_vpc.id
  region = var.region

  tags = {
    Name = "Internet Gateway"
  }
}


#####################
# NAT GATEWAY
#####################
# Elastic IP for NAT Gateway
resource "aws_eip" "nat_gateway_eip" {
  domain = "vpc"

  tags = {
    Name = "NAT Gateway EIP_public_1"
  }
}

# Nat Gateway in public subnet 1
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     = aws_subnet.public_subnet1.id

  depends_on = [aws_internet_gateway.gw] # Recommended

  tags = {
    Name = "NAT Gateway public 1"
  }
}


#####################
# AWS EC2 INSTANCE
#####################
# aws security group web_server_1
resource "aws_security_group" "web_server_1_sg" {
  name        = "web_server_1_sg"
  description = "Allow HTTP and SSH traffic"
  vpc_id      = aws_vpc.main_vpc.id

  tags = {
    Name = "Allow HTTP and SSH traffic on web_server_1"
  }
}

# aws security group web_server_1 ingress rules HTTP
resource "aws_vpc_security_group_ingress_rule" "web_server_1_sg_ingress_http" {
  cidr_ipv4         = var.all_destination_cidr
  from_port         = var.web_port
  ip_protocol       = "tcp"
  to_port           = var.web_port
  security_group_id = aws_security_group.web_server_1_sg.id

  tags = {
    Name = "Allow inbound HTTP traffic on web_server_1"
  }
}

# aws security group web_server_1 egress rules
resource "aws_vpc_security_group_egress_rule" "web_server_1_sg_egress" {
  ip_protocol       = "-1" # all protocols
  cidr_ipv4         = var.all_destination_cidr
  security_group_id = aws_security_group.web_server_1_sg.id

  tags = {
    Name = "Allow all outbound traffic on web_server_1"
  }
}

# aws security group web_server_1 ingress rules SSH
resource "aws_vpc_security_group_ingress_rule" "web_server_1_sg_ingress_ssh" {
  cidr_ipv4         = var.all_destination_cidr # change
  from_port         = var.ssh_port
  ip_protocol       = "tcp"
  to_port           = var.ssh_port
  security_group_id = aws_security_group.web_server_1_sg.id

  tags = {
    Name = "Allow inbound SSH traffic on web_server_1"
  }
}

# Instance EC2 web_server_1
resource "aws_instance" "web_server_1" {
  ami                         = data.aws_ssm_parameter.amzn2_linux.value
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_subnet2.id
  vpc_security_group_ids      = [aws_security_group.web_server_1_sg.id]
  user_data_replace_on_change = true
  key_name                    = aws_key_pair.web_server_key.key_name
  depends_on                  = [aws_key_pair.web_server_key]
  tags = {
    Name = "Web Server 1"
  }

  user_data = <<EOF
    #!/bin/bash
    # Installer Nginx
    sudo amazon-linux-extras install -y nginx1
    systemctl enable nginx
    systemctl start nginx

    # Install MariaDB client
    sudo yum install -y mariadb

    # Create a custom homepage
    echo "<html><head><title>Welcome to Web Server 1</title></head><body><h1>Welcome to Web Server 1</h1></body></html>" > /usr/share/nginx/html/index.html

    EOF
}

resource "aws_key_pair" "web_server_key" {
  key_name   = "web_server_key"
  public_key = file("web-server-key.pub")

  tags = {
    Name = "Key pair for web server access"
  }
}



#####################
# DB RDS
#####################
# RDS DB PRIMARY in private subnet 1
resource "aws_db_instance" "rds_db" {
  allocated_storage      = 10
  db_name                = "primarydb"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  username               = var.db_username
  password               = var.db_password
  parameter_group_name   = "default.mysql8.0"
  db_subnet_group_name   = aws_db_subnet_group.rds_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_db_sg.id]
  availability_zone      = aws_subnet.private_subnet1.availability_zone
  skip_final_snapshot    = true

  tags = {
    Name = "RDS DB"
  }
}

# RDS DB Subnet Group
resource "aws_db_subnet_group" "rds_db_subnet_group" {
  name       = "main"
  subnet_ids = [aws_subnet.private_subnet1.id, aws_subnet.private_subnet2.id]

  tags = {
    Name = "DB rds"
  }
}

# aws security group rds db primary
resource "aws_security_group" "rds_db_sg" {
  name        = "rds_db_sg"
  description = "Allow MySQL traffic from web server"
  vpc_id      = aws_vpc.main_vpc.id

  tags = {
    Name = "Allow MySQL traffic from web server to RDS DB"
  }
}
resource "aws_vpc_security_group_ingress_rule" "rds_db_sg_ingress_mysql" {

  security_group_id            = aws_security_group.rds_db_sg.id
  referenced_security_group_id = aws_security_group.web_server_1_sg.id
  from_port                    = var.mysql_port
  ip_protocol                  = "tcp"
  to_port                      = var.mysql_port

  tags = {
    Name = "Allow mysql traffic from web server to RDS DB"
  }
}

# Blocked with student access
# RDS DB secondary - read replica in private subnet 2
# resource "aws_db_instance" "rds_db_secondary" {
#   replicate_source_db    = aws_db_instance.rds_db.identifier
#   instance_class         = "db.t3.micro"
#   engine                 = "mysql"
#   vpc_security_group_ids = [aws_security_group.rds_db_sg.id]
#   availability_zone      = aws_subnet.private_subnet2.availability_zone


#   depends_on = [aws_db_instance.rds_db]
#   tags = {
#     Name = "RDS DB Secondary Read Replica"
#   }
# }

