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

# Create a Public Subnet
resource "aws_subnet" "VPC01-Public-SN" {
  vpc_id     = aws_vpc.VPC-01.id
  cidr_block = "192.168.1.0/24"

  tags = {
    Name = "VPC01-Public-SN"
  }
}

# Create a Private Subnet
resource "aws_subnet" "VPC01-Private-SN" {
  vpc_id     = aws_vpc.VPC-01.id
  cidr_block = "192.168.3.0/24"

  tags = {
    Name = "VPC01-Private-SN"
  }
}

# Create a Public Route Table
resource "aws_route_table" "VPC01-Public-RT" {
  vpc_id = aws_vpc.VPC-01.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.VPC01-IGW.id
  }

  tags = {
    Name = "VPC01-Public-RT"
  }
}

resource "aws_route_table_association" "VPC01-Public-RT-Association" {
  subnet_id      = aws_subnet.VPC01-Public-SN.id
  route_table_id = aws_route_table.VPC01-Public-RT.id
}

# Create a EIP
resource "aws_eip" "Nat-EIP" {
  domain   = "vpc"
}

# Create a Nat Gateway
resource "aws_nat_gateway" "VPC01-Nat_Gateway" {
  allocation_id = aws_eip.Nat-EIP.id
  subnet_id     = aws_subnet.VPC01-Public-SN.id

  tags = {
    Name = "VPC01-Nat_Gateway"
  }
}

# Create a Private Route Table
resource "aws_route_table" "VPC01-Private-RT" {
  vpc_id = aws_vpc.VPC-01.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.VPC01-Nat_Gateway.id
  }

  tags = {
    Name = "VPC01-Private-RT"
  }
}

resource "aws_route_table_association" "VPC01-Private-RT-Association" {
  subnet_id      = aws_subnet.VPC01-Private-SN.id
  route_table_id = aws_route_table.VPC01-Private-RT.id
}

# Create a Security Group
resource "aws_security_group" "VPC01-VM-NSG" {
  name        = "VPC01-VM-NSG"
  description = "Allow SSH inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.VPC-01.id

  tags = {
    Name = "VPC01-VM-NSG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.VPC01-VM-NSG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.VPC01-VM-NSG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# Create a Public Instance
resource "aws_instance" "VPC01-Public-VM" {
  ami           = "ami-0b3ba1acb76a70451"
  instance_type = "t3.micro"
  key_name      = "Terraform_Server_Key"
  subnet_id     = aws_subnet.VPC01-Public-SN.id
  vpc_security_group_ids  = [aws_security_group.VPC01-VM-NSG.id]
  associate_public_ip_address 	=  true

  tags = {
    Name = "VPC01-Public-VM"
  }
}

# Create a Private Instance
resource "aws_instance" "VPC01-Private-VM" {
  ami           = "ami-0b3ba1acb76a70451"
  instance_type = "t3.micro"
  key_name      = "Terraform_Server_Key"
  subnet_id     = aws_subnet.VPC01-Private-SN.id
  vpc_security_group_ids  = [aws_security_group.VPC01-VM-NSG.id]

  tags = {
    Name = "VPC01-Private-VM"
  }
}