resource "aws_vpc" "default" {
  cidr_block = "172.31.0.0/16"

  tags = {
    Name      = "default"
    Terraform = "true"
  }
}

resource "aws_subnet" "default_b" {
  cidr_block              = "172.31.16.0/20"
  vpc_id                  = "vpc-84271ded"
  availability_zone       = "eu-central-1b"
  map_public_ip_on_launch = "true"

  tags = {
    Name      = "default-b"
    Terraform = "true"
  }
}
