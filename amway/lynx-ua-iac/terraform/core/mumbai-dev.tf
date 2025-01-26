# VPC

resource "aws_vpc" "mumbai_dev" {
  provider                         = "aws.mumbai"
  cidr_block                       = "10.124.80.0/20"
  instance_tenancy                 = "default"
  enable_dns_support               = "true"
  enable_dns_hostnames             = "true"
  assign_generated_ipv6_cidr_block = "false"

  tags = {
    Name      = "AWS-EIA-IN-Hybris"
    Terraform = "true"
  }
}

# Route tables
resource "aws_default_route_table" "mumbai_main" {
  provider               = "aws.mumbai"
  default_route_table_id = "${aws_vpc.mumbai_dev.default_route_table_id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.mumbai_nat.id}"
  }

  route {
    cidr_block = "10.0.0.0/8"
    gateway_id = "${aws_vpn_gateway.epam_mumbai_main.id}"
  }

  route {
    cidr_block = "172.16.0.0/12"
    gateway_id = "${aws_vpn_gateway.epam_mumbai_main.id}"
  }

  tags = {
    Name      = "epam-main"
    Terraform = "true"
  }
}

resource "aws_route_table" "mumbai_nat" {
  provider = "aws.mumbai"
  vpc_id   = "${aws_vpc.mumbai_dev.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.mumbai_main.id}"
  }

  tags = {
    Name      = "epam-nat"
    Terraform = "true"
  }
}

resource "aws_route_table_association" "main_to_lambda_a" {
  provider       = "aws.mumbai"
  subnet_id      = "${aws_subnet.mumbai_dev_lambda_a.id}"
  route_table_id = "${aws_default_route_table.mumbai_main.id}"
}

resource "aws_route_table_association" "main_to_lambda_b" {
  provider       = "aws.mumbai"
  subnet_id      = "${aws_subnet.mumbai_dev_lambda_b.id}"
  route_table_id = "${aws_default_route_table.mumbai_main.id}"
}

resource "aws_route_table_association" "mumbai_nat" {
  provider       = "aws.mumbai"
  subnet_id      = "${aws_subnet.mumbai_nat.id}"
  route_table_id = "${aws_route_table.mumbai_nat.id}"
}

resource "aws_route_table_association" "main_to_kubernetes" {
  provider       = "aws.mumbai"
  subnet_id      = "${aws_subnet.mumbai_kubernetes.id}"
  route_table_id = "${aws_default_route_table.mumbai_main.id}"
}

resource "aws_route_table_association" "main_to_kubernetes_rds_a" {
  provider       = "aws.mumbai"
  subnet_id      = "${aws_subnet.mumbai_kubernetes_rds_a.id}"
  route_table_id = "${aws_default_route_table.mumbai_main.id}"
}

resource "aws_route_table_association" "main_to_kubernetes_rds_b" {
  provider       = "aws.mumbai"
  subnet_id      = "${aws_subnet.mumbai_kubernetes_rds_b.id}"
  route_table_id = "${aws_default_route_table.mumbai_main.id}"
}

# Subnets

resource "aws_subnet" "mumbai_dev_lambda_a" {
  provider                = "aws.mumbai"
  vpc_id                  = "${aws_vpc.mumbai_dev.id}"
  cidr_block              = "10.124.80.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = "false"

  tags = {
    Name      = "EPAM-lambda-a"
    Terraform = "true"
  }
}

resource "aws_subnet" "mumbai_dev_lambda_b" {
  provider                = "aws.mumbai"
  vpc_id                  = "${aws_vpc.mumbai_dev.id}"
  cidr_block              = "10.124.81.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = "false"

  tags = {
    Name      = "EPAM-lambda-b"
    Terraform = "true"
  }
}

resource "aws_subnet" "mumbai_nat" {
  provider                = "aws.mumbai"
  vpc_id                  = "${aws_vpc.mumbai_dev.id}"
  cidr_block              = "10.124.83.0/28"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = "false"

  tags = {
    Name      = "epam-nat"
    Terraform = "true"
  }
}

resource "aws_subnet" "mumbai_kubernetes" {
  provider                = "aws.mumbai"
  vpc_id                  = "${aws_vpc.mumbai_dev.id}"
  cidr_block              = "10.124.82.0/28"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = "false"

  tags = {
    Name      = "epam-kubernetes"
    Terraform = "true"
  }
}

resource "aws_subnet" "mumbai_kubernetes_rds_a" {
  provider                = "aws.mumbai"
  vpc_id                  = "${aws_vpc.mumbai_dev.id}"
  cidr_block              = "10.124.82.16/28"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = "false"

  tags = {
    Name      = "epam-kubernetes-rds-a"
    Terraform = "true"
  }
}

resource "aws_subnet" "mumbai_kubernetes_rds_b" {
  provider                = "aws.mumbai"
  vpc_id                  = "${aws_vpc.mumbai_dev.id}"
  cidr_block              = "10.124.82.32/28"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = "false"

  tags = {
    Name      = "epam-kubernetes-rds-b"
    Terraform = "true"
  }
}

# Network ACL
resource "aws_default_network_acl" "mumbai_dev" {
  provider               = "aws.mumbai"
  default_network_acl_id = "${aws_vpc.mumbai_dev.default_network_acl_id}"

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
    "${aws_subnet.mumbai_dev_lambda_a.id}",
    "${aws_subnet.mumbai_dev_lambda_b.id}",
    "${aws_subnet.mumbai_nat.id}",
    "${aws_subnet.mumbai_kubernetes.id}",
    "${aws_subnet.mumbai_kubernetes_rds_a.id}",
    "${aws_subnet.mumbai_kubernetes_rds_b.id}",
  ]

  tags = {
    Name      = "default"
    Terraform = "true"
  }
}

# Security group
resource "aws_default_security_group" "mumbai_dev" {
  provider = "aws.mumbai"
  vpc_id   = "${aws_vpc.mumbai_dev.id}"

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
resource "aws_vpc_peering_connection" "epam_mumbai_frankfurt" {
  provider    = "aws.mumbai"
  peer_vpc_id = "${aws_vpc.dev.id}"
  vpc_id      = "${aws_vpc.mumbai_dev.id}"

  accepter {
    allow_remote_vpc_dns_resolution = "true"
  }

  requester {
    allow_remote_vpc_dns_resolution = "false"
  }

  tags = {
    Name      = "EIA-Hybris-India to AWS-EIA-Hybris Frankfurt"
    Terraform = "true"
  }
}

resource "aws_customer_gateway" "epam_mumbai_1" {
  provider   = "aws.mumbai"
  bgp_asn    = "65124"
  ip_address = "13.232.72.78"
  type       = "ipsec.1"

  tags = {
    Name      = "epam-mumbai-gw-1"
    Terraform = "true"
  }
}

resource "aws_customer_gateway" "epam_mumbai_2" {
  provider   = "aws.mumbai"
  bgp_asn    = "65124"
  ip_address = "13.126.202.146"
  type       = "ipsec.1"

  tags = {
    Name      = "epam-mumbai-gw-2"
    Terraform = "true"
  }
}

resource "aws_vpn_gateway" "epam_mumbai_main" {
  provider = "aws.mumbai"
  vpc_id   = "${aws_vpc.mumbai_dev.id}"

  tags = {
    Name      = "epam-mumbai-main"
    Terraform = "true"
  }
}

resource "aws_vpn_connection" "epam_mumbai_amway_1" {
  provider            = "aws.mumbai"
  vpn_gateway_id      = "${aws_vpn_gateway.epam_mumbai_main.id}"
  customer_gateway_id = "${aws_customer_gateway.epam_mumbai_1.id}"
  type                = "ipsec.1"
  tunnel1_inside_cidr = "169.254.52.80/30"
  tunnel2_inside_cidr = "169.254.54.80/30"
  static_routes_only  = "false"

  tags = {
    Name      = "epam-mumbai-amway-1"
    Terraform = "true"
  }
}

resource "aws_vpn_connection" "epam_mumbai_amway_2" {
  provider            = "aws.mumbai"
  vpn_gateway_id      = "${aws_vpn_gateway.epam_mumbai_main.id}"
  customer_gateway_id = "${aws_customer_gateway.epam_mumbai_2.id}"
  type                = "ipsec.1"
  tunnel1_inside_cidr = "169.254.52.72/30"
  tunnel2_inside_cidr = "169.254.54.72/30"
  static_routes_only  = "false"

  tags = {
    Name      = "epam-mumbai-amway-2"
    Terraform = "true"
  }
}

resource "aws_security_group" "mumbai_allow_tls_to_apigw_endpoint" {
  provider    = "aws.mumbai"
  name        = "allow_tls_to_apigw_endpoint"
  description = "Allow TLS inbound traffic to private API Gateway endpoint"
  vpc_id      = "${aws_vpc.mumbai_dev.id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "allow_tls_to_apigw_endpoint"
    Terraform = "true"
  }
}

# VPC Endpoint for Documen Generator
resource "aws_vpc_endpoint" "mumbai_private_apigw" {
  provider            = "aws.mumbai"
  vpc_id              = "${aws_vpc.mumbai_dev.id}"
  service_name        = "com.amazonaws.ap-south-1.execute-api"
  private_dns_enabled = true
  vpc_endpoint_type   = "Interface"

  subnet_ids         = ["${aws_subnet.mumbai_dev_lambda_a.id}", "${aws_subnet.mumbai_dev_lambda_b.id}"]
  security_group_ids = ["${aws_security_group.mumbai_allow_tls_to_apigw_endpoint.id}"]
}
