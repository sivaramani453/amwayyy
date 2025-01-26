# VPC
resource "aws_default_vpc" "frankfurt_default" {
  provider = "aws.frankfurt"

  tags = {
    Name      = "default"
    Terraform = "true"
  }
}

# Route tables
resource "aws_default_route_table" "frankfurt_default" {
  provider               = "aws.frankfurt"
  default_route_table_id = "${aws_default_vpc.frankfurt_default.default_route_table_id}"

  tags = {
    Name      = "default"
    Terraform = "true"
  }
}

# Subnets
resource "aws_default_subnet" "frankfurt_default_a" {
  provider          = "aws.frankfurt"
  availability_zone = "eu-central-1a"

  tags = {
    Name      = "default-a"
    Terraform = "true"
  }
}

resource "aws_default_subnet" "frankfurt_default_b" {
  provider          = "aws.frankfurt"
  availability_zone = "eu-central-1b"

  tags = {
    Name      = "default-b"
    Terraform = "true"
  }
}

resource "aws_default_subnet" "frankfurt_default_c" {
  provider          = "aws.frankfurt"
  availability_zone = "eu-central-1c"

  tags = {
    Name      = "default-c"
    Terraform = "true"
  }
}

# Network ACL
resource "aws_default_network_acl" "frankfurt_default" {
  provider               = "aws.frankfurt"
  default_network_acl_id = "${aws_default_vpc.frankfurt_default.default_network_acl_id}"

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
    "${aws_default_subnet.frankfurt_default_a.id}",
    "${aws_default_subnet.frankfurt_default_b.id}",
    "${aws_default_subnet.frankfurt_default_c.id}",
  ]

  tags = {
    Name      = "default"
    Terraform = "true"
  }
}

# Security group
resource "aws_default_security_group" "frankfurt_default" {
  provider = "aws.frankfurt"
  vpc_id   = "${aws_default_vpc.frankfurt_default.id}"

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

# DHCP
resource "aws_default_vpc_dhcp_options" "frankfurt_default" {
  provider = "aws.frankfurt"

  tags = {
    Name      = "default"
    Terraform = "true"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "frankfurt_default" {
  provider = "aws.frankfurt"
  vpc_id   = "${aws_default_vpc.frankfurt_default.id}"

  tags = {
    Name      = "default"
    Terraform = "true"
  }
}
