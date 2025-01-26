# VPC

resource "aws_vpc" "virginia_dev" {
  provider                         = "aws.virginia"
  cidr_block                       = "10.133.24.0/24"
  instance_tenancy                 = "default"
  enable_dns_support               = "true"
  enable_dns_hostnames             = "true"
  assign_generated_ipv6_cidr_block = "false"

  tags = {
    Name      = "EPAM-VIRGINIA"
    Terraform = "true"
  }
}

# Route tables
resource "aws_default_route_table" "virginia_main" {
  provider               = "aws.virginia"
  default_route_table_id = "${aws_vpc.virginia_dev.default_route_table_id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.virginia_nat.id}"
  }

  route {
    cidr_block = "10.0.0.0/8"
    gateway_id = "${aws_vpn_gateway.epam_virginia_main.id}"
  }

  route {
    cidr_block = "172.16.0.0/12"
    gateway_id = "${aws_vpn_gateway.epam_virginia_main.id}"
  }

  tags = {
    Name      = "MAIN-EPAM-VIRGINIA"
    Terraform = "true"
  }
}

resource "aws_route_table" "virginia_nat" {
  provider = "aws.virginia"
  vpc_id   = "${aws_vpc.virginia_dev.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.virginia_main.id}"
  }

  tags = {
    Name      = "NAT-ROUTE-TABLE"
    Terraform = "true"
  }
}

resource "aws_route_table_association" "main_to_dev_a" {
  provider       = "aws.virginia"
  subnet_id      = "${aws_subnet.virginia_dev_a.id}"
  route_table_id = "${aws_default_route_table.virginia_main.id}"
}

resource "aws_route_table_association" "main_to_dev_b" {
  provider       = "aws.virginia"
  subnet_id      = "${aws_subnet.virginia_dev_b.id}"
  route_table_id = "${aws_default_route_table.virginia_main.id}"
}

resource "aws_route_table_association" "main_to_dev_c" {
  provider       = "aws.virginia"
  subnet_id      = "${aws_subnet.virginia_dev_c.id}"
  route_table_id = "${aws_default_route_table.virginia_main.id}"
}

resource "aws_route_table_association" "virginia_nat" {
  provider       = "aws.virginia"
  subnet_id      = "${aws_subnet.virginia_nat.id}"
  route_table_id = "${aws_route_table.virginia_nat.id}"
}

resource "aws_route_table_association" "virginia_public_a" {
  provider       = "aws.virginia"
  subnet_id      = "${aws_subnet.virginia_public_a.id}"
  route_table_id = "${aws_route_table.virginia_nat.id}"
}

resource "aws_route_table_association" "virginia_public_b" {
  provider       = "aws.virginia"
  subnet_id      = "${aws_subnet.virginia_public_b.id}"
  route_table_id = "${aws_route_table.virginia_nat.id}"
}

resource "aws_route_table_association" "virginia_public_c" {
  provider       = "aws.virginia"
  subnet_id      = "${aws_subnet.virginia_public_c.id}"
  route_table_id = "${aws_route_table.virginia_nat.id}"
}

# Subnets

resource "aws_subnet" "virginia_dev_a" {
  provider                = "aws.virginia"
  vpc_id                  = "${aws_vpc.virginia_dev.id}"
  cidr_block              = "10.133.24.0/26"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = "false"

  tags = {
    Name      = "EPAM-environment-a"
    Terraform = "true"
  }
}

resource "aws_subnet" "virginia_dev_b" {
  provider                = "aws.virginia"
  vpc_id                  = "${aws_vpc.virginia_dev.id}"
  cidr_block              = "10.133.24.64/26"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = "false"

  tags = {
    Name      = "EPAM-environment-b"
    Terraform = "true"
  }
}

resource "aws_subnet" "virginia_dev_c" {
  provider                = "aws.virginia"
  vpc_id                  = "${aws_vpc.virginia_dev.id}"
  cidr_block              = "10.133.24.192/27"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = "false"

  tags = {
    Name      = "EPAM-environment-c"
    Terraform = "true"
  }
}

resource "aws_subnet" "virginia_public_a" {
  provider                = "aws.virginia"
  vpc_id                  = "${aws_vpc.virginia_dev.id}"
  cidr_block              = "10.133.24.128/28"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = "false"

  tags = {
    Name      = "EPAM-public-a"
    Terraform = "true"
  }
}

resource "aws_subnet" "virginia_public_b" {
  provider                = "aws.virginia"
  vpc_id                  = "${aws_vpc.virginia_dev.id}"
  cidr_block              = "10.133.24.144/28"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = "false"

  tags = {
    Name      = "EPAM-public-b"
    Terraform = "true"
  }
}

resource "aws_subnet" "virginia_public_c" {
  provider                = "aws.virginia"
  vpc_id                  = "${aws_vpc.virginia_dev.id}"
  cidr_block              = "10.133.24.160/28"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = "false"

  tags = {
    Name      = "EPAM-public-c"
    Terraform = "true"
  }
}

resource "aws_subnet" "virginia_nat" {
  provider                = "aws.virginia"
  vpc_id                  = "${aws_vpc.virginia_dev.id}"
  cidr_block              = "10.133.24.240/28"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = "false"

  tags = {
    Name      = "NAT-subnet"
    Terraform = "true"
  }
}

# Network ACL
resource "aws_default_network_acl" "virginia_dev" {
  provider               = "aws.virginia"
  default_network_acl_id = "${aws_vpc.virginia_dev.default_network_acl_id}"

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
    "${aws_subnet.virginia_dev_a.id}",
    "${aws_subnet.virginia_dev_b.id}",
    "${aws_subnet.virginia_dev_c.id}",
    "${aws_subnet.virginia_nat.id}",
    "${aws_subnet.virginia_public_a.id}",
    "${aws_subnet.virginia_public_b.id}",
    "${aws_subnet.virginia_public_c.id}",
  ]

  tags = {
    Name      = "default"
    Terraform = "true"
  }
}

# Security group
resource "aws_default_security_group" "virginia_dev" {
  provider = "aws.virginia"
  vpc_id   = "${aws_vpc.virginia_dev.id}"

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

# VPN

resource "aws_customer_gateway" "epam_virginia" {
  provider   = "aws.virginia"
  bgp_asn    = "65000"
  ip_address = "167.23.24.79"
  type       = "ipsec.1"

  tags = {
    Name      = "EPAM-VIRGINIA-GW"
    Terraform = "true"
  }
}

resource "aws_vpn_gateway" "epam_virginia_main" {
  provider = "aws.virginia"
  vpc_id   = "${aws_vpc.virginia_dev.id}"

  tags = {
    Name      = "VPG-EPAM-VIRGINIA"
    Terraform = "true"
  }
}

resource "aws_vpn_connection" "epam_virginia_amway" {
  provider            = "aws.virginia"
  vpn_gateway_id      = "${aws_vpn_gateway.epam_virginia_main.id}"
  customer_gateway_id = "${aws_customer_gateway.epam_virginia.id}"
  type                = "ipsec.1"
  tunnel1_inside_cidr = "169.254.7.104/30"
  tunnel2_inside_cidr = "169.254.7.108/30"
  static_routes_only  = "false"

  tags = {
    Name      = "EPAM-VIRGINIA-TO-AMWAY"
    Terraform = "true"
  }
}
