terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-west-1"
}

# Create a VPC
resource "aws_vpc" "VPC-01" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "VPC-01"
  }
}

# Create & attach the IGW
resource "aws_internet_gateway" "VPC01-IGW" {
  vpc_id = aws_vpc.VPC-01.id

  tags = {
    Name = "VPC01-IGW"
  }
}


#create a public subnet
resource "aws_subnet" "public-subnet" {
  vpc_id     = aws_vpc.VPC-01.id
  cidr_block = "192.168.1.0/24"

  tags = {
    Name = "PUBLIC-SUBNET"
  }
}


#create a private subnet
resource "aws_subnet" "private-subnet" {
  vpc_id     = aws_vpc.VPC-01.id
  cidr_block = "192.168.2.0/24"

  tags = {
    Name = "PRIVATE-SUBNET"
  }
}


#route table for public subnet
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.VPC-01.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.VPC01-IGW.id
  }

  tags = {
    Name = "public-rt"
  }
}

#create route table association for public subnet
resource "aws_route_table_association" "public-rt-association" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-rt.id
}



#create elastic IP for NAT gateway
resource "aws_eip" "nat-eip" {
  domain   = "vpc"
}

#NAT gateway for private subnet
resource "aws_nat_gateway" "VPC01-NAT" {
  allocation_id = aws_eip.nat-eip.id
  subnet_id     = aws_subnet.public-subnet.id

  tags = {
    Name = "VPC01-NAT"
  }
}


#route table for private subnet
resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.VPC-01.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.VPC01-NAT.id
  }

  tags = {
    Name = "private-rt"
  }
}

#create route table association for private subnet
resource "aws_route_table_association" "private-rt-association" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private-rt.id
}

#create security group 
resource "aws_security_group" "NSG" {
  name        = "NSG"
  description = "Allow SSH inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.VPC-01.id

  tags = {
    Name = "NSG"
  }
}

#allow inbound SSH traffic from anywhere
resource "aws_vpc_security_group_ingress_rule" "allow_SSH_ipv4" {
  security_group_id = aws_security_group.NSG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

#create egress rule to allow all outbound traffic
resource "aws_vpc_security_group_egress_rule" "allow_alltraffic_ipv4" {
  security_group_id = aws_security_group.NSG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

#key pair for EC2 instance
resource "aws_key_pair" "terraform_key" {
  key_name   = "terraform_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 email@example.com"
}

#public instance
resource "aws_instance" "PUBLIC-EC2" {
  ami           = "ami-0d02821d8216364ac"
  instance_type = "t3.micro"
  key_name = aws_key_pair.terraform_key.key_name
  subnet_id = aws_subnet.public-subnet.id
  vpc_security_group_ids = [aws_security_group.NSG.id]
  associate_public_ip_address = true

  tags = {
    Name = "PUBLIC-EC2"
  }
}

#private instance
resource "aws_instance" "PRIVATE-EC2" {
  ami           = "ami-0d02821d8216364ac"
  instance_type = "t3.micro"
  key_name = aws_key_pair.terraform_key.key_name
  subnet_id = aws_subnet.private-subnet.id
  vpc_security_group_ids = [aws_security_group.NSG.id]
  associate_public_ip_address = false

  tags = {
    Name = "PRIVATE-EC2"
  }
}