# catalogue des variables acceptées. Il définit quels paramètres sont configurables (ex: type d'instance, région), 
# leur type (string, number) et leur valeur par défaut.

#####################
# Configuration AWS PROVIDER REGION
#####################
variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

#####################
# CONFIG VPC
#####################
# Configuration VPC CIDR BLOCK
variable "subnet_cidr_vpc" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# Configuration DNS HOSTNAMES
variable "dns_hostnames" {
  description = "Enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

#####################
# CONFIG SUBNETS
#####################
# Configuration map_public_ip_on_launch PUBLIC SUBNET
variable "map_public_ip_on_launch" {
  description = "Enable automatic assignment of public IPv4 addresses to instances"
  type        = bool
  default     = true
}

# Configuration CIDR Public Subnet 
variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.2.0/24"]
}

# Configuration CIDR Private Subnet
variable "private_subnet_cidr" {
  description = "CIDR block for private subnet"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.3.0/24"]
}

# Availiability Zones
variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# Instance Type
variable "instance_type" {
  description = "Type of instance to deploy"
  type        = string
  default     = "t2.micro"
}

#####################
# CONFIG Security Group
#####################
# Security Group for web server
variable "all_destination_cidr" {
  description = "CIDR block for allowing all traffic within the VPC"
  type        = string
  default     = "0.0.0.0/0"
}

variable "web_port" {
  description = "Port for web server access"
  type        = number
  default     = 80
}

variable "ssh_port" {
  description = "Port for SSH access"
  type        = number
  default     = 22
}

#####################
# CONFIG RDS
#####################
# RDS DB password
variable "db_password" {
  description = "RDS root user password"
  type        = string
  sensitive   = true
}

variable "db_username" {
  description = "RDS root username"
  type        = string
  sensitive   = true
}

variable "mysql_port" {
  description = "mysql port"
  type        = number
  default     = 3306
}