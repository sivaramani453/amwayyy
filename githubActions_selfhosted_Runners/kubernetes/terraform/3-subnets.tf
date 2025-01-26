# Resource: aws_subnet
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
resource "aws_subnet" "private-subnet-1a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnet1_cidr
  availability_zone = "us-east-1a"

  tags = {
    "Name"                            = "${var.vpc_name}-private-subnet1"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/demo"      = "owned"
  }
}



resource "aws_subnet" "private-subnet-1b" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.subnet5_cidr
  availability_zone = "us-east-1c"

  tags = {
    Name = "${var.vpc_name}-private-subnet3"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/demo"      = "owned"
  }
}

resource "aws_subnet" "private-subnet-1c" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.subnet2_cidr
  availability_zone = "us-east-1b"

  tags = {
    Name = "${var.vpc_name}-private-subnet2"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/demo"      = "owned"
  }
}


resource "aws_subnet" "public-us-east-1a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnet3_cidr
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"

  tags = {
    "Name"                       = "${var.vpc_name}-public-subnet1"
    "kubernetes.io/role/elb"     = "1"
    "kubernetes.io/cluster/demo" = "owned"
  }
}

resource "aws_subnet" "public-us-east-1b" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnet4_cidr
  map_public_ip_on_launch = true
  availability_zone = "us-east-1b"

  tags = {
    "Name"                       = "${var.vpc_name}-public-subnet2"
    "kubernetes.io/role/elb"     = "1"
    "kubernetes.io/cluster/demo" = "owned"
  }
}
