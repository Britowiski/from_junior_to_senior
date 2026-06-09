# Minha rede principal isolada
resource "aws_vpc" "primeira-rede" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "VPC-Junior-to-senior"
  }
}
#VPC e Subnet sempre irão estar conectadas, na subrede sempre chamará a vpc 
#Minha sub-rede

resource "aws_subnet" "minha-subrede" {
  vpc_id     = aws_vpc.primeira-rede.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "Subnet-Juninho"
  }
}

#Aqui é onde vai o gateway que libera acesso a rede externa 
#No gateway sempre chamará a aws vpc pelo id aws-vpc.nome da vpc

resource "aws_internet_gateway" "meu-gateway" {
  vpc_id = aws_vpc.primeira-rede.id
  tags = {
    Name = "IGW-juninho-to-senior"
  }
}

#na route sempre usara também a vpc pelo id

resource "aws_route_table" "tabela_publica" {
  vpc_id = aws_vpc.primeira-rede.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.meu-gateway.id
  }

  tags = {
    Name = "RouteTable-Publica"
  }
}

#Aqui é onde vai ser ligado a sub-rede na tabela de roteamento
resource "aws_route_table_association" "Ligando-subrede-na-tabela" {
  subnet_id      = aws_subnet.minha-subrede.id
  route_table_id = aws_route_table.tabela_publica.id
}

#Criando meu security group 
resource "aws_security_group" "liberar-web" {
  name        = "liberar-http-docker"
  description = "abre a porta 80 para acessar o Apache"
  vpc_id      = aws_vpc.primeira-rede.id

  ingress {
    description = "Permite http de qualquer lugar"
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

  ingress {
    description = "Permite o SSH do nosso computador"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Firewall-Web"
  }
}


#Aqui é onde é criado o servidor no EC2 com o Apache no docker
resource "aws_instance" "meu-servidor" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.small"
  subnet_id                   = aws_subnet.minha-subrede.id
  vpc_security_group_ids      = [aws_security_group.liberar-web.id]
  associate_public_ip_address = true

  key_name = aws_key_pair.chave_ssh_ansible.key_name

  tags = {
    Name = "Servidor-Ansible-Vazio"
  }
}

resource "aws_key_pair" "chave_ssh_ansible" {
  key_name   = "chave-ansible-aws"
  public_key = file("~/.ssh/chave_ansible.pub")
}