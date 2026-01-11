//Démo 
output "aws_instance_public_dns" {
  description = "Nom d'hôte DNS public de l'instance EC2"
  value       = "http://${aws_instance.nginx1.public_dns}"
}

//Exercice
output "vpc_id" {
  description = "ID du VPC créé"
  value       = aws_vpc.app.id
}

output "public_subnet_id" {
  description = "ID du sous-réseau public"
  value       = aws_subnet.public_subnet1.id
}
