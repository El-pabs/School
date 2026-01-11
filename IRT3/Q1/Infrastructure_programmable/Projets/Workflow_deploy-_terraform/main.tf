/*
Cette configuration Terraform permet de mettre en place une application web basique sur AWS à l'aide d'une instance EC2 exécutant Nginx.
Elle comprend les composants réseau nécessaires, tels qu'un VPC, un sous-réseau, une passerelle Internet et des groupes de sécurité.
Des identifiants AWS sont requis pour appliquer cette configuration. Ils peuvent être définis à l'aide de variables d'environnement ou de l'interface CLI AWS.
*/

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Configuration du Backend S3 (Sans DynamoDB pour éviter les erreurs de droits)
  backend "s3" {
    bucket  = "terraform-state-heh-workflow-terraform"
    key     = "global/s3/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  region = var.aws_region
}

##################################################################################
# DATA
##################################################################################

data "aws_ssm_parameter" "amzn2_linux" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

##################################################################################
# RESOURCES
##################################################################################

# NETWORKING #
resource "aws_vpc" "app" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = var.vpc_enable_dns_hostnames

  tags = merge(local.common_tags, { Name = lower("${local.naming_prefix}-vpc") }) 
  # Ajout du tag Name pour le VPC exemple "dev-app-vpc"
  # ca sert à identifier le VPC dans la console AWS
}

resource "aws_internet_gateway" "app" {
  vpc_id = aws_vpc.app.id
  tags   = local.common_tags
}

resource "aws_subnet" "public_subnet1" {
  cidr_block              = var.vpc_subnet_cidr
  vpc_id                  = aws_vpc.app.id
  map_public_ip_on_launch = var.map_public_ip_on_launch
  tags                    = merge(local.common_tags, { Name = lower("${local.naming_prefix}-public-subnet1") })
}

# ROUTING #
resource "aws_route_table" "app" {
  vpc_id = aws_vpc.app.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app.id
  }

  tags = merge(local.common_tags, { Name = lower("${local.naming_prefix}-rtb") })
}

resource "aws_route_table_association" "app_subnet1" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.app.id
}

# SECURITY GROUPS #
resource "aws_security_group" "nginx_sg" {
  name   = lower("${local.naming_prefix}-nginx_sg")
  vpc_id = aws_vpc.app.id

  # Règle 1 : Autoriser HTTP standard (Port 80)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Règle 2 : Autoriser HTTPS standard (Port 443)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Règle 3 : Autoriser le port applicatif défini dans les variables (ex: 8080)
  ingress {
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound internet access (Sortie autorisée partout)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

# INSTANCES #
resource "aws_instance" "nginx1" {
  ami                         = nonsensitive(data.aws_ssm_parameter.amzn2_linux.value)
  instance_type               = var.ec2_instance_type
  subnet_id                   = aws_subnet.public_subnet1.id
  vpc_security_group_ids      = [aws_security_group.nginx_sg.id]
  user_data_replace_on_change = true
  tags                        = merge(local.common_tags, { Name = lower("${local.naming_prefix}-nginx1") })

  user_data = templatefile("./templates/startup_script.tpl", {
    environment = var.environment
  })

}
