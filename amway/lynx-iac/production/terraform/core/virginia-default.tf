# VPC
resource "aws_default_vpc" "virginia_default" {
  provider = "aws.virginia"

  tags = {
    Name      = "default"
    Terraform = "true"
  }
}

# Route tables
resource "aws_default_route_table" "virginia_default" {
  provider               = "aws.virginia"
  default_route_table_id = "${aws_default_vpc.virginia_default.default_route_table_id}"

  tags = {
    Name      = "default"
    Terraform = "true"
  }
}

# Subnets
resource "aws_default_subnet" "virginia_default_a" {
  provider          = "aws.virginia"
  availability_zone = "us-east-1a"

  tags = {
    Name      = "default-a"
    Terraform = "true"
  }
}

resource "aws_default_subnet" "virginia_default_b" {
  provider          = "aws.virginia"
  availability_zone = "us-east-1b"

  tags = {
    Name      = "default-b"
    Terraform = "true"
  }
}

resource "aws_default_subnet" "virginia_default_c" {
  provider          = "aws.virginia"
  availability_zone = "us-east-1c"

  tags = {
    Name      = "default-c"
    Terraform = "true"
  }
}

resource "aws_default_subnet" "virginia_default_d" {
  provider          = "aws.virginia"
  availability_zone = "us-east-1d"

  tags = {
    Name      = "default-d"
    Terraform = "true"
  }
}

resource "aws_default_subnet" "virginia_default_e" {
  provider          = "aws.virginia"
  availability_zone = "us-east-1e"

  tags = {
    Name      = "default-e"
    Terraform = "true"
  }
}

resource "aws_default_subnet" "virginia_default_f" {
  provider          = "aws.virginia"
  availability_zone = "us-east-1f"

  tags = {
    Name      = "default-f"
    Terraform = "true"
  }
}

# Network ACL
resource "aws_default_network_acl" "virginia_default" {
  provider               = "aws.virginia"
  default_network_acl_id = "${aws_default_vpc.virginia_default.default_network_acl_id}"

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
    "${aws_default_subnet.virginia_default_a.id}",
    "${aws_default_subnet.virginia_default_b.id}",
    "${aws_default_subnet.virginia_default_c.id}",
    "${aws_default_subnet.virginia_default_d.id}",
    "${aws_default_subnet.virginia_default_e.id}",
    "${aws_default_subnet.virginia_default_f.id}",
  ]

  tags = {
    Name      = "default"
    Terraform = "true"
  }
}

# Security group
resource "aws_default_security_group" "virginia_default" {
  provider = "aws.virginia"
  vpc_id   = "${aws_default_vpc.virginia_default.id}"

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
resource "aws_default_vpc_dhcp_options" "virginia_default" {
  provider = "aws.virginia"

  tags = {
    Name      = "default"
    Terraform = "true"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "virginia_default" {
  provider = "aws.virginia"
  vpc_id   = "${aws_default_vpc.virginia_default.id}"

  tags = {
    Name      = "default"
    Terraform = "true"
  }
}
