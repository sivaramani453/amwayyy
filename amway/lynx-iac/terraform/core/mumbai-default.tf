# VPC
resource "aws_default_vpc" "mumbai_default" {
  provider = "aws.mumbai"

  tags = {
    Name      = "default"
    Terraform = "true"
  }
}

# Route tables
resource "aws_default_route_table" "mumbai_default" {
  provider               = "aws.mumbai"
  default_route_table_id = "${aws_default_vpc.mumbai_default.default_route_table_id}"

  tags = {
    Name      = "default"
    Terraform = "true"
  }
}

# Subnets
resource "aws_default_subnet" "mumbai_default_a" {
  provider          = "aws.mumbai"
  availability_zone = "ap-south-1a"

  tags = {
    Name      = "default-a"
    Terraform = "true"
  }
}

resource "aws_default_subnet" "mumbai_default_b" {
  provider          = "aws.mumbai"
  availability_zone = "ap-south-1b"

  tags = {
    Name      = "default-b"
    Terraform = "true"
  }
}

resource "aws_default_subnet" "mumbai_default_c" {
  provider          = "aws.mumbai"
  availability_zone = "ap-south-1c"

  tags = {
    Name      = "default-c"
    Terraform = "true"
  }
}

# Network ACL
resource "aws_default_network_acl" "mumbai_default" {
  provider               = "aws.mumbai"
  default_network_acl_id = "${aws_default_vpc.mumbai_default.default_network_acl_id}"

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  subnet_ids = [
    "${aws_default_subnet.mumbai_default_a.id}",
    "${aws_default_subnet.mumbai_default_b.id}",
    "${aws_default_subnet.mumbai_default_c.id}",
  ]

  tags = {
    Name      = "default"
    Terraform = "true"
  }
}

# Security group
resource "aws_default_security_group" "mumbai_default" {
  provider = "aws.mumbai"
  vpc_id   = "${aws_default_vpc.mumbai_default.id}"

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "default"
    Terraform = "true"
  }
}
