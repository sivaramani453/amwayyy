locals {
  frankfurt_azs                      = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  frankfurt_kubernetes_subnet_cidrs  = ["10.130.56.0/26", "10.130.56.64/26", "10.130.56.128/26"]
  frankfurt_ci_subnet_cidrs          = ["10.130.56.192/28", "10.130.56.208/28", "10.130.56.224/28"]
  frankfurt_database_subnets         = ["10.130.56.240/28", "10.130.57.0/28", "10.130.57.16/28"]
  frankfurt_lambda_subnet_cidrs      = ["10.130.57.32/27", "10.130.57.64/27", "10.130.57.96/27"]
  frankfurt_public_subnets           = ["10.130.57.128/27", "10.130.57.160/27", "10.130.57.192/27"]
  frankfurt_rancher_subnet_cidrs     = ["10.130.57.224/28", "10.130.57.240/28", "10.130.58.0/28"]
  frankfurt_rancher_alb_subnet_cidrs = ["10.130.58.16/28", "10.130.58.32/28", "10.130.58.48/28"]
  frankfurt_address_validation_cidrs = ["10.130.58.64/28", "10.130.58.80/28", "10.130.58.96/28"]
  frankfurt_subnet_postfixes         = ["a", "b", "c"]
  frankfurt_amway_dns_servers        = ["10.232.150.41", "172.30.54.10"]
}

module "s3_bucket" {
  source  = "cloudposse/s3-bucket/aws"
  version = "0.3.0"

  user_enabled       = "false"
  name               = "lambda-functions"
  region             = "eu-central-1"
  stage              = "prod-ru"
  namespace          = "amway"
  versioning_enabled = "false"

  tags {
    Terraform   = "true"
    Environment = "prod"
  }
}

module "frankfurt_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "1.67.0"

  providers = {
    aws = "aws.frankfurt"
  }

  name = "amway-russia-production"

  cidr = "10.130.56.0/22"

  # Subnets
  azs                                = "${local.frankfurt_azs}"
  database_subnets                   = "${local.frankfurt_database_subnets}"
  public_subnets                     = "${local.frankfurt_public_subnets}"
  propagate_private_route_tables_vgw = true

  # DNS
  enable_dns_hostnames             = true
  enable_dns_support               = true
  enable_dhcp_options              = true
  dhcp_options_domain_name_servers = "${local.frankfurt_amway_dns_servers}"

  # NAT
  enable_nat_gateway     = true
  one_nat_gateway_per_az = true

  public_subnet_tags = {
    Name      = "frankfurt-public-nat"
    Terraform = "true"
  }

  database_subnet_tags = {
    Name = "rds-subnet"
  }

  nat_gateway_tags = {
    Name = "frankfurt-nat-gw"
  }

  nat_eip_tags = {
    Name = "frankfurt-nat-eip"
  }

  vpc_tags = {
    Name        = "amway-russia-production"
    Environment = "prod"
  }

  tags = {
    Terraform = "true"
  }
}

resource "aws_subnet" "frankfurt_kubernetes" {
  provider = "aws.frankfurt"

  count             = "${length(local.frankfurt_kubernetes_subnet_cidrs)}"
  vpc_id            = "${module.frankfurt_vpc.vpc_id}"
  cidr_block        = "${element(local.frankfurt_kubernetes_subnet_cidrs, count.index)}"
  availability_zone = "${element(local.frankfurt_azs, count.index)}"

  tags = {
    Name      = "kubernetes-private-${element(local.frankfurt_subnet_postfixes, count.index)}"
    Terraform = "true"
  }
}

resource "aws_subnet" "frankfurt_lambda" {
  provider          = "aws.frankfurt"
  count             = "${length(local.frankfurt_lambda_subnet_cidrs)}"
  vpc_id            = "${module.frankfurt_vpc.vpc_id}"
  cidr_block        = "${element(local.frankfurt_lambda_subnet_cidrs, count.index)}"
  availability_zone = "${element(local.frankfurt_azs, count.index)}"

  tags = {
    Name      = "lambda-private-${element(local.frankfurt_subnet_postfixes, count.index)}"
    Terraform = "true"
  }
}

resource "aws_subnet" "frankfurt_ci" {
  provider          = "aws.frankfurt"
  count             = "${length(local.frankfurt_ci_subnet_cidrs)}"
  vpc_id            = "${module.frankfurt_vpc.vpc_id}"
  cidr_block        = "${element(local.frankfurt_ci_subnet_cidrs, count.index)}"
  availability_zone = "${element(local.frankfurt_azs, count.index)}"

  tags = {
    Name      = "ci-private-${element(local.frankfurt_subnet_postfixes, count.index)}"
    Terraform = "true"
  }
}

resource "aws_subnet" "frankfurt_rancher" {
  provider          = "aws.frankfurt"
  count             = "${length(local.frankfurt_rancher_subnet_cidrs)}"
  vpc_id            = "${module.frankfurt_vpc.vpc_id}"
  cidr_block        = "${element(local.frankfurt_rancher_subnet_cidrs, count.index)}"
  availability_zone = "${element(local.frankfurt_azs, count.index)}"

  tags = {
    Name      = "rancher-private-${element(local.frankfurt_subnet_postfixes, count.index)}"
    Terraform = "true"
  }
}

resource "aws_subnet" "frankfurt_rancher_alb" {
  provider          = "aws.frankfurt"
  count             = "${length(local.frankfurt_rancher_alb_subnet_cidrs)}"
  vpc_id            = "${module.frankfurt_vpc.vpc_id}"
  cidr_block        = "${element(local.frankfurt_rancher_alb_subnet_cidrs, count.index)}"
  availability_zone = "${element(local.frankfurt_azs, count.index)}"

  tags = {
    Name      = "rancher_alb-private-${element(local.frankfurt_subnet_postfixes, count.index)}"
    Terraform = "true"
  }
}

resource "aws_subnet" "frankfurt_address_validation" {
  provider          = "aws.frankfurt"
  count             = "${length(local.frankfurt_address_validation_cidrs)}"
  vpc_id            = "${module.frankfurt_vpc.vpc_id}"
  cidr_block        = "${element(local.frankfurt_address_validation_cidrs, count.index)}"
  availability_zone = "${element(local.frankfurt_azs, count.index)}"

  tags = {
    Name      = "address-validation-private-${element(local.frankfurt_subnet_postfixes, count.index)}"
    Terraform = "true"
  }
}

resource "aws_route_table_association" "frankfurt_private" {
  provider = "aws.frankfurt"
  count    = "${length(concat(local.frankfurt_kubernetes_subnet_cidrs, local.frankfurt_lambda_subnet_cidrs, local.frankfurt_ci_subnet_cidrs, local.frankfurt_rancher_subnet_cidrs, local.frankfurt_rancher_alb_subnet_cidrs, local.frankfurt_address_validation_cidrs))}"

  subnet_id      = "${element(concat(aws_subnet.frankfurt_kubernetes.*.id, aws_subnet.frankfurt_lambda.*.id, aws_subnet.frankfurt_ci.*.id, aws_subnet.frankfurt_rancher.*.id, aws_subnet.frankfurt_rancher_alb.*.id, aws_subnet.frankfurt_address_validation.*.id), count.index)}"
  route_table_id = "${element(module.frankfurt_vpc.database_route_table_ids, count.index)}"
}

resource "aws_security_group" "frankfurt_allow_tls_to_apigw_endpoint" {
  provider    = "aws.frankfurt"
  name        = "allow_tls_to_apigw_endpoint"
  description = "Allow TLS inbound traffic to private API Gateway endpoint"
  vpc_id      = "${module.frankfurt_vpc.vpc_id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
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

resource "aws_vpc_endpoint" "frankfurt_private_apigw" {
  provider            = "aws.frankfurt"
  vpc_id              = "${module.frankfurt_vpc.vpc_id}"
  service_name        = "com.amazonaws.eu-central-1.execute-api"
  private_dns_enabled = true
  vpc_endpoint_type   = "Interface"

  subnet_ids         = ["${aws_subnet.frankfurt_lambda.0.id}", "${aws_subnet.frankfurt_lambda.1.id}", "${aws_subnet.frankfurt_lambda.2.id}"]
  security_group_ids = ["${aws_security_group.frankfurt_allow_tls_to_apigw_endpoint.id}"]
}

# VPN
resource "aws_customer_gateway" "frankfurt_production" {
  provider   = "aws.frankfurt"
  bgp_asn    = "65525"
  ip_address = "167.23.75.14"
  type       = "ipsec.1"

  tags = {
    Name      = "frankfurt-production"
    Terraform = "true"
  }
}

resource "aws_vpn_gateway" "frankfurt_production" {
  provider = "aws.frankfurt"
  vpc_id   = "${module.frankfurt_vpc.vpc_id}"

  tags = {
    Name      = "frankfurt-production"
    Terraform = "true"
  }
}

resource "aws_vpn_connection" "frankfurt_production" {
  provider            = "aws.frankfurt"
  vpn_gateway_id      = "${aws_vpn_gateway.frankfurt_production.id}"
  customer_gateway_id = "${aws_customer_gateway.frankfurt_production.id}"
  type                = "ipsec.1"
  tunnel1_inside_cidr = "169.254.60.80/30"
  tunnel2_inside_cidr = "169.254.60.84/30"
  static_routes_only  = "false"

  tags = {
    Name      = "frankfurt-production"
    Terraform = "true"
  }
}

# VPN Route
resource "aws_vpn_gateway_route_propagation" "frankfurt_production" {
  provider       = "aws.frankfurt"
  count          = "${length(concat(local.frankfurt_database_subnets))}"
  vpn_gateway_id = "${aws_vpn_gateway.frankfurt_production.id}"
  route_table_id = "${element(module.frankfurt_vpc.database_route_table_ids, count.index)}"
}

# VPN Route public subnets
resource "aws_vpn_gateway_route_propagation" "frankfurt_production_pub" {
  provider       = "aws.frankfurt"
  count          = "${length(concat(local.frankfurt_public_subnets))}"
  vpn_gateway_id = "${aws_vpn_gateway.frankfurt_production.id}"
  route_table_id = "${element(module.frankfurt_vpc.public_route_table_ids, count.index)}"
}

# SSH
resource "aws_key_pair" "amway-microservices-production-frankfurt" {
  provider   = "aws.frankfurt"
  key_name   = "amway-microservices-production"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDq6LDAcJZ5F1/ErM4OowluzmQJdWMW/9RuYQnrj+/dferFeNegGthKD6oI8oBy1TIx8WPf++R7xy8O4tzTxBS8V4zprujfydEgG0btdR2rr1MhqHsfmoJOK/1K5HJqDfGNcWY+N2oNK84njMgRVMSIWWjTfF6R0BLObuvCIRRiJLh3ItVmZGiYa0At0bjxShlRb9eldOGTa5OogJoE1ygfxTMjnccdr7gw+S+BFQl4zCSAQohgwep11wSLn/SawsWRhz1bLzPRVkU7JuR6d6CqgGpoOUOn4AMiT9Bq/RhxtRSS5BtOKF4NyVDSe1BoT1ElqHubR6Y/J71KB2WLKFSv root@CentOS7x64"
}

resource "aws_acm_certificate" "frankfurt_main" {
  provider          = "aws.frankfurt"
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

resource "aws_route53_record" "frankfurt_cert_validation" {
  name    = "${aws_acm_certificate.frankfurt_main.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.frankfurt_main.domain_validation_options.0.resource_record_type}"
  zone_id = "${aws_route53_zone.main.zone_id}"
  records = ["${aws_acm_certificate.frankfurt_main.domain_validation_options.0.resource_record_value}"]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "frankfurt_cert_validation" {
  provider                = "aws.frankfurt"
  certificate_arn         = "${aws_acm_certificate.frankfurt_main.arn}"
  validation_record_fqdns = ["${aws_route53_record.frankfurt_cert_validation.fqdn}"]
}
