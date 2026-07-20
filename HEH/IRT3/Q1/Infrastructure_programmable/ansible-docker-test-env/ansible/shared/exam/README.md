***

### Objectif
Lancer 2 serveurs Web sur AWS avec Terraform, puis installer Apache et une page web personnalisée dessus avec Ansible, le tout dans un environnement de labo restreint (AWS Academy).

### 1. Les Fichiers à créer (4 fichiers)

Tous ces fichiers doivent être dans **le même dossier**.

#### `main.tf` (L'infrastructure)
Crée le réseau, les règles de sécurité, et les 2 machines.
```hcl
terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}

provider "aws" { region = "us-east-1" }

# --- CONFIGURATION ---
locals {
  project = "demo-ansible"
}

# --- RÉSEAU (VPC) ---
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = { Name = "${local.project}-vpc" }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "${local.project}-gw" }
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"
  tags = { Name = "${local.project}-subnet" }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = { Name = "${local.project}-rt" }
}

resource "aws_route_table_association" "a" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.rt.id
}

# --- SÉCURITÉ ---
resource "aws_security_group" "web_sg" {
  name = "${local.project}-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- SERVEURS ---
data "aws_ssm_parameter" "linux_ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

data "aws_key_pair" "lab_key" {
  key_name = "vockey"
  include_public_key = true
}

resource "aws_instance" "web" {
  count = 2
  ami = nonsensitive(data.aws_ssm_parameter.linux_ami.value)
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name = data.aws_key_pair.lab_key.key_name
  tags = { Name = "${local.project}-web-${count.index + 1}" }
}

# --- INVENTAIRE AUTOMATIQUE ---
resource "local_file" "inventory" {
  content = <<EOT
[web_servers]
${aws_instance.web[0].public_ip} ansible_user=ec2-user ansible_ssh_private_key_file=./labsuser.pem
${aws_instance.web[1].public_ip} ansible_user=ec2-user ansible_ssh_private_key_file=./labsuser.pem
EOT
  filename = "inventory.ini"
}
```

#### `playbook.yml` (La configuration)
Installe Python 3.8 (requis) et Apache.
```yaml
- hosts: web_servers
  become: yes
  gather_facts: no
  vars:
    server_name: "Serveur AWS"
    message: "Site déployé par Terraform & Ansible"

  tasks:
    - name: Install Python 3.8
      raw: "amazon-linux-extras install python3.8 -y"
      changed_when: false

    - name: Set python interpreter
      set_fact:
        ansible_python_interpreter: /usr/bin/python3.8

    - name: Install Apache (httpd)
      shell: "yum install -y httpd"

    - name: Start Apache
      service:
        name: httpd
        state: started
        enabled: yes

    - name: Deploy Site
      template:
        src: index.html.j2
        dest: /var/www/html/index.html
        mode: '0644'
```

#### `index.html.j2` (Le site web)
```html
<h1> {{ server_name }} </h1>
<h2> {{ message }} </h2>
```

#### `labsuser.pem` (La clé secrète)
1.  Va sur le site de ton labo AWS (Vocareum).
2.  Clique sur **AWS Details** -> **Download SSH Key**.
3.  Déplace le fichier `labsuser.pem` dans ton dossier.
4.  **Important :** Change les permissions pour qu'il soit sécurisé.
    ```bash
    chmod 400 labsuser.pem
    ```

***

### 2. Les Commandes à lancer

Ouvre ton terminal **Linux / WSL** dans le dossier et lance :

1.  **Préparation** :
    ```bash
    terraform init
    ```

2.  **Lancement des serveurs** :
    ```bash
    terraform apply -auto-approve
    ```
    *(Attends 30 secondes après la fin pour laisser le temps aux serveurs de démarrer)*.

3.  **Installation du site** :
    ```bash
    ansible-playbook -i inventory.ini playbook.yml --ssh-common-args='-o StrictHostKeyChecking=no'
    ```

### 3. Le Résultat
Ouvre le fichier `inventory.ini` généré dans le dossier. Prends une des IPs affichées et va dessus avec ton navigateur :
`http://X.X.X.X`
