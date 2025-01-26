module "s3_bucket" {
  source  = "cloudposse/s3-bucket/aws"
  version = "0.3.0"

  user_enabled       = "false"
  name               = "lambda-functions"
  region             = "eu-central-1"
  stage              = "dev"
  namespace          = "amway"
  versioning_enabled = "false"

  tags {
    Terraform = "true"
  }
}

resource "aws_vpc" "dev" {
  cidr_block = "10.130.112.0/20"

  tags {
    Name      = "AWS-EIA-Hybris"
    Terraform = "true"
  }
}

resource "aws_subnet" "mgmt" {
  cidr_block        = "10.130.115.0/24"
  vpc_id            = "vpc-1fbfbe76"
  availability_zone = "eu-central-1a"

  tags {
    Name      = "EPAM-Mgmt"
    Terraform = "true"
  }
}

resource "aws_subnet" "environment_a" {
  cidr_block        = "10.130.123.0/24"
  vpc_id            = "vpc-1fbfbe76"
  availability_zone = "eu-central-1a"

  tags {
    Name      = "EPAM-environment-a"
    Terraform = "true"
  }
}

resource "aws_subnet" "environment_b" {
  cidr_block        = "10.130.113.64/27"
  vpc_id            = "vpc-1fbfbe76"
  availability_zone = "eu-central-1b"

  tags {
    Name      = "EPAM-environment-b"
    Terraform = "true"
  }
}

resource "aws_subnet" "environment_c" {
  cidr_block        = "10.130.113.128/27"
  vpc_id            = "vpc-1fbfbe76"
  availability_zone = "eu-central-1c"

  tags {
    Name      = "EPAM-environment-c"
    Terraform = "true"
  }
}

resource "aws_subnet" "dev_debug" {
  cidr_block        = "10.130.122.0/24"
  vpc_id            = "vpc-1fbfbe76"
  availability_zone = "eu-central-1b"

  tags {
    Name      = "EPAM-dev_debug"
    Terraform = "true"
  }
}

resource "aws_subnet" "ci_a" {
  cidr_block        = "10.130.116.0/24"
  vpc_id            = "vpc-1fbfbe76"
  availability_zone = "eu-central-1a"

  tags {
    Name      = "EPAM-CI-a"
    Terraform = "true"
  }
}

resource "aws_subnet" "ci_b" {
  cidr_block        = "10.130.118.0/24"
  vpc_id            = "vpc-1fbfbe76"
  availability_zone = "eu-central-1b"

  tags {
    Name      = "EPAM-CI-b"
    Terraform = "true"
  }
}

resource "aws_subnet" "ci_c" {
  cidr_block        = "10.130.114.0/24"
  vpc_id            = "vpc-1fbfbe76"
  availability_zone = "eu-central-1c"

  tags {
    Name      = "EPAM-CI-c"
    Terraform = "true"
  }
}

resource "aws_subnet" "core_a" {
  cidr_block        = "10.130.119.0/24"
  vpc_id            = "vpc-1fbfbe76"
  availability_zone = "eu-central-1a"

  tags {
    Name      = "EPAM-core-a"
    Terraform = "true"
  }
}

resource "aws_subnet" "core_b" {
  cidr_block        = "10.130.125.0/24"
  vpc_id            = "vpc-1fbfbe76"
  availability_zone = "eu-central-1b"

  tags {
    Name      = "EPAM-core-b"
    Terraform = "true"
  }
}

resource "aws_subnet" "core_c" {
  cidr_block        = "10.130.117.0/27"
  vpc_id            = "vpc-1fbfbe76"
  availability_zone = "eu-central-1c"

  tags {
    Name      = "EPAM-core-c"
    Terraform = "true"
  }
}

resource "aws_subnet" "middleware_b" {
  cidr_block        = "10.130.113.0/28"
  vpc_id            = "vpc-1fbfbe76"
  availability_zone = "eu-central-1b"

  tags {
    Name      = "EPAM-Middleware-b"
    Terraform = "true"
  }
}

data "aws_region" "current" {}

resource "aws_security_group" "frankfurt_allow_tls_to_apigw_endpoint" {
  name        = "allow_tls_to_apigw_endpoint"
  description = "Allow TLS inbound traffic to private API Gateway endpoint"
  vpc_id      = "${aws_vpc.dev.id}"

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

# VPC Endpoint for new SMS microservice
resource "aws_vpc_endpoint" "frankfurt_private_apigw" {
  vpc_id              = "${aws_vpc.dev.id}"
  service_name        = "com.amazonaws.eu-central-1.execute-api"
  private_dns_enabled = true
  vpc_endpoint_type   = "Interface"

  subnet_ids         = ["${aws_subnet.core_a.id}", "${aws_subnet.core_b.id}", "${aws_subnet.core_c.id}"]
  security_group_ids = ["${aws_security_group.frankfurt_allow_tls_to_apigw_endpoint.id}"]
}

# VPN
resource "aws_customer_gateway" "epam_frankfurt" {
  bgp_asn    = "65525"
  ip_address = "167.23.75.14"
  type       = "ipsec.1"

  tags = {
    Name      = "epam-frankfurt-gw"
    Terraform = "true"
  }
}

resource "aws_vpn_gateway" "epam_frankfurt_main" {
  vpc_id = "${aws_vpc.dev.id}"

  tags = {
    Name      = "epam-frankfurt-main"
    Terraform = "true"
  }
}

resource "aws_vpn_connection" "epam_frankfurt_amway" {
  vpn_gateway_id      = "${aws_vpn_gateway.epam_frankfurt_main.id}"
  customer_gateway_id = "${aws_customer_gateway.epam_frankfurt.id}"
  type                = "ipsec.1"
  tunnel1_inside_cidr = "169.254.0.88/30"
  tunnel2_inside_cidr = "169.254.0.96/30"
  static_routes_only  = "false"

  tags = {
    Name      = "epam-frankfurt-amway"
    Terraform = "true"
  }
}
