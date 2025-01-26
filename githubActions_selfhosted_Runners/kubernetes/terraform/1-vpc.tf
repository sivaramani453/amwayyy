resource "aws_vpc" "vpc" {
  cidr_block       = var.cidr
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
}


resource "aws_internet_gateway" "vpc-igw" {
    vpc_id = aws_vpc.vpc.id
	tags = {
        Name = var.IGW_name
    }
}



resource "aws_security_group" "terraform-allow_all" {
  name        = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    }
}

