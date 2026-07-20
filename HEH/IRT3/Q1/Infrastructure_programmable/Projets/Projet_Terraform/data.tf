data "aws_ssm_parameter" "amzn2_linux" { 
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}
 # Permet de récupérer des infos existantes sur le cloud. Ici on recupère l'AMI (Amazon Machine Image)