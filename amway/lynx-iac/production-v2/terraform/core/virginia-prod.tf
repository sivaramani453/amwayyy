locals {
  virginia_azs = [
    "us-east-1a",
    "us-east-1b",
    "us-east-1c",
    "us-east-1d",
    "us-east-1e",
    "us-east-1f",
  ]

  virginia_kubernetes_subnets = [
    "10.133.232.0/27",
    "10.133.232.32/27",
    "10.133.232.64/27",
    "10.133.232.96/27",
    "10.133.232.128/27",
    "10.133.232.160/27",
  ]

  virginia_database_subnets = [
    "10.133.233.128/28",
    "10.133.233.144/28",
    "10.133.233.160/28",
    "10.133.233.176/28",
    "10.133.233.192/28",
    "10.133.233.208/28",
  ]

  virginia_public_subnets = [
    "10.133.232.192/27",
    "10.133.232.224/27",
    "10.133.233.0/27",
    "10.133.233.32/27",
    "10.133.233.64/27",
    "10.133.233.96/27",
  ]

  virginia_lambda_subnets = [
    "10.133.233.224/28",
    "10.133.233.240/28",
    "10.133.234.0/28",
    "10.133.234.16/28",
    "10.133.234.32/28",
    "10.133.234.48/28",
  ]

  virginia_subnet_postfixes  = ["a", "b", "c", "d", "e", "f"]
  virginia_amway_dns_servers = ["172.30.54.10", "172.21.64.101"]
}

module "virginia_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "1.67.0"

  providers = {
    aws = "aws.virginia"
  }

  name = "amway-russia-production"

  cidr = "10.133.232.0/22"

  # Subnets
  azs                                = "${local.virginia_azs}"
  database_subnets                   = "${local.virginia_database_subnets}"
  public_subnets                     = "${local.virginia_public_subnets}"
  propagate_private_route_tables_vgw = true

  # DNS
  enable_dns_hostnames             = true
  enable_dns_support               = true
  enable_dhcp_options              = true
  dhcp_options_domain_name_servers = "${local.virginia_amway_dns_servers}"

  # NAT
  enable_nat_gateway     = true
  one_nat_gateway_per_az = true

  public_subnet_tags = {
    Name      = "virginia-public-nat"
    Terraform = "true"
  }

  database_subnet_tags = {
    Name = "rds-subnet"
  }

  nat_gateway_tags = {
    Name = "virginia-nat-gw"
  }

  nat_eip_tags = {
    Name = "virginia-nat-eip"
  }

  vpc_tags = {
    Name        = "amway-russia-production"
    Environment = "prod"
  }

  tags = {
    Terraform = "true"
  }
}

resource "aws_subnet" "virginia_kubernetes" {
  provider = "aws.virginia"

  count             = "${length(local.virginia_kubernetes_subnets)}"
  vpc_id            = "${module.virginia_vpc.vpc_id}"
  cidr_block        = "${element(local.virginia_kubernetes_subnets, count.index)}"
  availability_zone = "${element(local.virginia_azs, count.index)}"

  tags = {
    Name      = "kubernetes-private-${element(local.virginia_subnet_postfixes, count.index)}"
    Terraform = "true"
  }
}

resource "aws_subnet" "virginia_lambda" {
  provider          = "aws.virginia"
  count             = "${length(local.virginia_lambda_subnets)}"
  vpc_id            = "${module.virginia_vpc.vpc_id}"
  cidr_block        = "${element(local.virginia_lambda_subnets, count.index)}"
  availability_zone = "${element(local.virginia_azs, count.index)}"

  tags = {
    Name      = "lambda-private-${element(local.virginia_subnet_postfixes, count.index)}"
    Terraform = "true"
  }
}

resource "aws_route_table_association" "virginia_private" {
  provider = "aws.virginia"
  count    = "${length(concat(local.virginia_kubernetes_subnets, local.virginia_lambda_subnets))}"

  subnet_id      = "${element(concat(aws_subnet.virginia_kubernetes.*.id, aws_subnet.virginia_lambda.*.id), count.index)}"
  route_table_id = "${element(module.virginia_vpc.database_route_table_ids, count.index)}"
}

# VPN
resource "aws_customer_gateway" "virginia_production" {
  provider   = "aws.virginia"
  bgp_asn    = "65000"
  ip_address = "167.23.24.79"
  type       = "ipsec.1"

  tags = {
    Name      = "virginia-production"
    Terraform = "true"
  }
}

resource "aws_vpn_gateway" "virginia_production" {
  provider = "aws.virginia"
  vpc_id   = "${module.virginia_vpc.vpc_id}"

  tags = {
    Name      = "virginia-production"
    Terraform = "true"
  }
}

resource "aws_vpn_connection" "virginia_production" {
  provider            = "aws.virginia"
  vpn_gateway_id      = "${aws_vpn_gateway.virginia_production.id}"
  customer_gateway_id = "${aws_customer_gateway.virginia_production.id}"
  type                = "ipsec.1"
  tunnel1_inside_cidr = "169.254.8.232/30"
  tunnel2_inside_cidr = "169.254.8.236/30"
  static_routes_only  = "false"

  tags = {
    Name      = "virginia-production"
    Terraform = "true"
  }
}

# VPN Route
resource "aws_vpn_gateway_route_propagation" "virginia_production" {
  provider       = "aws.virginia"
  count          = "${length(concat(local.virginia_database_subnets))}"
  vpn_gateway_id = "${aws_vpn_gateway.virginia_production.id}"
  route_table_id = "${element(module.virginia_vpc.database_route_table_ids, count.index)}"
}

# VPN Route public subnets
resource "aws_vpn_gateway_route_propagation" "virginia_production_pub" {
  provider       = "aws.virginia"
  count          = "${length(concat(local.virginia_public_subnets))}"
  vpn_gateway_id = "${aws_vpn_gateway.virginia_production.id}"
  route_table_id = "${element(module.virginia_vpc.public_route_table_ids, count.index)}"
}

# SSH
resource "aws_key_pair" "amway-microservices-production-virginia" {
  provider   = "aws.virginia"
  key_name   = "amway-microservices-production"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDq6LDAcJZ5F1/ErM4OowluzmQJdWMW/9RuYQnrj+/dferFeNegGthKD6oI8oBy1TIx8WPf++R7xy8O4tzTxBS8V4zprujfydEgG0btdR2rr1MhqHsfmoJOK/1K5HJqDfGNcWY+N2oNK84njMgRVMSIWWjTfF6R0BLObuvCIRRiJLh3ItVmZGiYa0At0bjxShlRb9eldOGTa5OogJoE1ygfxTMjnccdr7gw+S+BFQl4zCSAQohgwep11wSLn/SawsWRhz1bLzPRVkU7JuR6d6CqgGpoOUOn4AMiT9Bq/RhxtRSS5BtOKF4NyVDSe1BoT1ElqHubR6Y/J71KB2WLKFSv root@CentOS7x64"
}

resource "aws_acm_certificate" "virginia_main" {
  provider          = "aws.virginia"
  domain_name       = "*.ru.eia.amway.net"
  validation_method = "DNS"

  tags = {
    Environment = "production"
    Terraform   = "true"
  }

  lifecycle {
    create_before_destroy = true
  }
}
