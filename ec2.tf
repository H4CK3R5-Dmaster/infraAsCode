resource "aws_instance" "bastion-sandbox-général" {
  ami                    = "ami-07789e07c5f839ff7"
  subnet_id              = aws_subnet.private-network.id
  vpc_security_group_ids = [aws_security_group.sg-sandbox-général.id]
  instance_type          = "t2.micro"
  key_name               = "sandbox-general"
  security_groups        = [aws_security_group.sg-sandbox-général.id]
  tags   = {
    Name = "bastion-reseau"
  }
}


resource "aws_eip" "bastion-sandbox-général" {
  vpc = true
}

resource "aws_eip_association" "bastion-sandbox-général" {
  instance_id   = aws_instance.bastion-sandbox-général.id
  allocation_id = aws_eip.bastion-sandbox-général.id
}


