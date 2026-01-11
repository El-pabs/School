# Définit ce que Terraform doit afficher (print) à la fin

# VPC Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main_vpc.id
}

output "cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main_vpc.cidr_block
}

# Subnet Outputs
output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value = [
    aws_subnet.public_subnet1.id,
    aws_subnet.public_subnet2.id
  ]
}

# Web Server Outputs
output "web_server_dns" {
  description = "Public DNS of the web server instance"
  value       = "http://${aws_instance.web_server_1.public_dns}"
}

output "web_server_ip" {
  description = "Public IP of the web server instance"
  value       = "http://${aws_instance.web_server_1.public_ip}"
}

# RDS Outputs
output "rds_hostname" {
  description = "RDS instance hostname"
  value       = aws_db_instance.rds_db.address
  sensitive   = true
}

output "rds_port" {
  description = "RDS instance port"
  value       = aws_db_instance.rds_db.port
  sensitive   = true
}

output "rds_username" {
  description = "RDS instance root username"
  value       = aws_db_instance.rds_db.username
  sensitive   = true
}

output "db_instance_endpoint" {
  description = "The connection endpoint"
  value       = aws_db_instance.rds_db.endpoint
}
