resource "aws_vpc" "vpc-sandbox-général" {
  cidr_block = "10.0.0.0/16" #permette de spécifier une plage d'adresses IP
  tags = {
    vpc-Yname = "vpc-sandbox-général"
  }
}

resource "aws_subnet" "public-network" {
  cidr_block = "10.0.1.0/24"
  vpc_id     = aws_vpc.vpc-sandbox-général.id
  tags = {
    Name = "subnet-public-sandbox-général"
  }
}

resource "aws_subnet" "private-network" {
  cidr_block = "10.0.2.0/24"
  vpc_id     = aws_vpc.vpc-sandbox-général.id
  tags = {
    Name = "subnet-private-sandbox-général"
  }
}

resource "aws_internet_gateway" "igw-sandbox-général" {
  vpc_id = aws_vpc.vpc-sandbox-général.id
  tags = {
    Name = "igw-sandbox-général"
  }
}


resource "aws_eip" "eip-ngw" {
  vpc = true #pour avoir une adresse IP. Booléen si l'EIP est dans un VPC ou non. Par défaut true
  tags = {
    Name = "eip-reseau-sandbox-général"
  }
}

resource "aws_nat_gateway" "ngw" {
  subnet_id = aws_subnet.public-network #mettre notre natgateway sur le subnet publique
  allocation_id = aws_eip.eip-ngw.id #Permet à AWS de gérer l'association
  tags = {
    Name = "ngw-sandbox-général"
  }
}

resource "aws_route_table" "public-network" {
  vpc_id = aws_vpc.vpc-sandbox-général.id #L'ID du VPC. Obligatoire
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-sandbox-général.id #Identifiant d'une passerelle Internet.
  }

  tags = {
    Name = "public-rt-sandbox-général"
  }
}

resource "aws_route_table" "private-network" {
  vpc_id = aws_vpc.vpc-sandbox-général.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }

  tags = {
    Name = "private-rt-sandbox-général"
  }
}

resource "aws_route_table_association" "public" { #Pour créer une association entre une table de routage et un sous-réseau
  route_table_id = aws_route_table.public-network.id # chaque table de routage est associé à un subnet
  subnet_id = aws_subnet.public-network.id
}

resource "aws_route_table_association" "private" { #associer les routes tables au subnet privée
  route_table_id = aws_route_table.private-network.id
  subnet_id = aws_subnet.private-network.id
}

# groupe de security juste pour le ssh port 22
resource "aws_security_group" "sg-sandbox-général" {
  name = "groupe de security lab reseau"
  description = "groupe de security reseau"
  vpc_id = aws_vpc.vpc-sandbox-général.id
  tags = {
    Name = "sg-reseau"
  }


  ingress {#Bloc de configuration pour les règles d'entrée. Peut être spécifié plusieurs fois pour chaque règle d'entrée.
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "RDP"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }



  egress {#Bloc de configuration pour les règles de sortie. Peut être spécifié plusieurs fois pour chaque règle de sortie.
    from_port        = 0 #Port de démarrage
    to_port          = 0 #Port de fin de plage
    protocol         = "-1" #-1 sémantiquement équivalent à all, qui n'est pas une valeur valide ici
    cidr_blocks      = ["0.0.0.0/0"]
  }
}