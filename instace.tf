#Login access
provider "aws" {
  region     = "us-east-1"
  access_key = "access key"
  secret_key = "secret key"
}

#Creating a VPC
resource "aws_vpc" "onyekavpc" {
  cidr_block           = "192.168.0.0/24"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  tags = {
    Name = "onyekavpc"
  }
}

#Creating Subnet in VPC
resource "aws_subnet" "onyekasubnet" {
  vpc_id                  = aws_vpc.onyekavpc.id
  cidr_block              = "192.168.0.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "onyekasubnet"
  }
}

#Whitelisted IPs
locals {
  whitelist_ips_5439 = {
    syedsa01 = { ip = " 192.168.0.0/24", description = "Sadiya" }
  }
}

#Create Security group
resource "aws_security_group" "dlsg" {
  name        = "dlsg"
  description = "Allow SSH and HTTPS inbound traffic"
  vpc_id      = aws_vpc.onyekavpc.id // change to vpc-0975c2917a65806e0

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    #cidr_blocks = [each.value.ip]
    cidr_blocks = [aws_vpc.onyekavpc.cidr_block]
  }

  tags = {
    Name = "dlsg"
  }
}

resource "aws_security_group_rule" "allow_SSH" {
  #for_each    = local.whitelist_ips_5439

  type              = "ingress"
  description       = "SSH from VPC"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.dlsg.id
  #cidr_blocks = [each.value.ip]
  cidr_blocks = [aws_vpc.onyekavpc.cidr_block]
}

resource "aws_security_group_rule" "allow_HTTPS" {
  #for_each    = local.whitelist_ips_5439
  type              = "ingress"
  description       = "HTTPS from VPC"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.dlsg.id
  #cidr_blocks = [each.value.ip]
  cidr_blocks = [aws_vpc.onyekavpc.cidr_block]

}


#Create EC2 instance
resource "aws_instance" "onyekainstance" {
  ami = "ami-052efd3df9dad4825" // Amazon AMI
  # ami                    = "ami-0280f3286512b1b99" // Deep Learning Ubuntu 18.04
  instance_type = "t2.micro" // Amazon free tier
  # instance_type          = "p3dn.24xlarge"  // Deep learing instance type
  key_name               = "onyekey"
  subnet_id              = aws_subnet.onyekasubnet.id //change to subnet-0bb4a8198b2d5e47b
  vpc_security_group_ids = [aws_security_group.dlsg.id]
  tags = {
    Name = "onyekainstance"
  }
}
