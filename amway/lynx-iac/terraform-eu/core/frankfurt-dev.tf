locals {
  frankfurt_azs                   = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  frankfurt_ci_subnet_cidrs       = ["10.130.224.0/25", "10.130.224.128/25", "10.130.225.0/25"]
  frankfurt_env_subnet_cidrs      = ["10.130.225.128/26", "10.130.225.192/26", "10.130.226.0/27"]
  frankfurt_database_subnet_cidrs = ["10.130.226.32/27", "10.130.226.64/27", "10.130.226.96/27"]
  frankfurt_lambda_subnet_cidrs   = ["10.130.226.128/27", "10.130.226.160/27", "10.130.226.192/27"]
  frankfurt_public_subnet_cidrs   = ["10.130.226.224/27", "10.130.227.0/27", "10.130.227.32/27"]
  frankfurt_core_subnet_cidrs     = ["10.130.227.64/26", "10.130.227.128/26", "10.130.227.192/26"]
  frankfurt_subnet_postfixes      = ["a", "b", "c"]
  frankfurt_amway_dns_servers     = ["10.232.150.41", "172.30.54.10", "172.30.54.140"]

  vpn_subnet_cidrs = ["10.0.0.0/8"]

  amway_common_tags {
    Terraform     = "true"
    ApplicationID = "APP1433689"
    Environment   = "DEV"
  }

  amway_data_tags {
    DataClassification = "Internal"
  }
}

module "s3_bucket" {
  source  = "cloudposse/s3-bucket/aws"
  version = "0.3.0"

  user_enabled       = "false"
  name               = "lambda-functions"
  region             = "eu-central-1"
  stage              = "dev-eu"
  namespace          = "amway"
  versioning_enabled = "false"

  tags = "${merge(local.amway_common_tags, local.amway_data_tags)}"
}

module "frankfurt_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> v1.0"

  providers = {
    aws = "aws.frankfurt"
  }

  name = "amway-europe-hybris-dev"

  cidr = "10.130.224.0/22"

  # Subnets
  azs                                = "${local.frankfurt_azs}"
  database_subnets                   = "${local.frankfurt_database_subnet_cidrs}"
  public_subnets                     = "${local.frankfurt_public_subnet_cidrs}"
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
    Name = "frankfurt-public-nat"
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
    Name = "amway-europe-hybris-dev"
  }

  tags = "${local.amway_common_tags}"
}

resource "aws_subnet" "frankfurt_ci" {
  provider          = "aws.frankfurt"
  count             = "${length(local.frankfurt_ci_subnet_cidrs)}"
  vpc_id            = "${module.frankfurt_vpc.vpc_id}"
  cidr_block        = "${element(local.frankfurt_ci_subnet_cidrs, count.index)}"
  availability_zone = "${element(local.frankfurt_azs, count.index)}"

  tags = "${merge(local.amway_common_tags, map("Name", "ci-private-${element(local.frankfurt_subnet_postfixes, count.index)}"))}"
}

resource "aws_subnet" "frankfurt_env" {
  provider          = "aws.frankfurt"
  count             = "${length(local.frankfurt_env_subnet_cidrs)}"
  vpc_id            = "${module.frankfurt_vpc.vpc_id}"
  cidr_block        = "${element(local.frankfurt_env_subnet_cidrs, count.index)}"
  availability_zone = "${element(local.frankfurt_azs, count.index)}"

  tags = "${merge(local.amway_common_tags, map("Name", "env-private-${element(local.frankfurt_subnet_postfixes, count.index)}"))}"
}

resource "aws_subnet" "frankfurt_lambda" {
  provider          = "aws.frankfurt"
  count             = "${length(local.frankfurt_lambda_subnet_cidrs)}"
  vpc_id            = "${module.frankfurt_vpc.vpc_id}"
  cidr_block        = "${element(local.frankfurt_lambda_subnet_cidrs, count.index)}"
  availability_zone = "${element(local.frankfurt_azs, count.index)}"

  tags = "${merge(local.amway_common_tags, map("Name", "lambda-private-${element(local.frankfurt_subnet_postfixes, count.index)}"))}"
}

resource "aws_subnet" "frankfurt_core" {
  provider          = "aws.frankfurt"
  count             = "${length(local.frankfurt_core_subnet_cidrs)}"
  vpc_id            = "${module.frankfurt_vpc.vpc_id}"
  cidr_block        = "${element(local.frankfurt_core_subnet_cidrs, count.index)}"
  availability_zone = "${element(local.frankfurt_azs, count.index)}"

  tags = "${merge(local.amway_common_tags, map("Name", "core-private-${element(local.frankfurt_subnet_postfixes, count.index)}"))}"
}

resource "aws_route_table_association" "frankfurt_private" {
  provider = "aws.frankfurt"
  count    = "${length(concat(local.frankfurt_ci_subnet_cidrs, local.frankfurt_env_subnet_cidrs, local.frankfurt_lambda_subnet_cidrs, local.frankfurt_core_subnet_cidrs))}"

  subnet_id      = "${element(concat(aws_subnet.frankfurt_ci.*.id, aws_subnet.frankfurt_env.*.id, aws_subnet.frankfurt_lambda.*.id, aws_subnet.frankfurt_core.*.id), count.index)}"
  route_table_id = "${element(module.frankfurt_vpc.database_route_table_ids, count.index)}"
}

module "apigw_endpoint_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 2.0"

  providers = {
    aws = "aws.frankfurt"
  }

  name        = "allow_tls_to_apigw_endpoint"
  description = "Allow TLS inbound traffic to private API Gateway endpoint"
  vpc_id      = "${module.frankfurt_vpc.vpc_id}"

  ingress_cidr_blocks = "${local.vpn_subnet_cidrs}"
  ingress_rules       = ["https-443-tcp"]

  egress_rules = ["all-all"]

  tags = "${local.amway_common_tags}"
}

resource "aws_vpc_endpoint" "frankfurt_private_apigw" {
  provider            = "aws.frankfurt"
  vpc_id              = "${module.frankfurt_vpc.vpc_id}"
  service_name        = "com.amazonaws.eu-central-1.execute-api"
  private_dns_enabled = true
  vpc_endpoint_type   = "Interface"

  subnet_ids         = ["${aws_subnet.frankfurt_lambda.0.id}", "${aws_subnet.frankfurt_lambda.1.id}", "${aws_subnet.frankfurt_lambda.2.id}"]
  security_group_ids = ["${module.apigw_endpoint_sg.this_security_group_id}"]
}

# VPN
resource "aws_customer_gateway" "frankfurt_dev" {
  provider   = "aws.frankfurt"
  bgp_asn    = "65525"
  ip_address = "167.23.75.14"
  type       = "ipsec.1"

  tags = "${merge(local.amway_common_tags, map("Name", "frankfurt-hybris-dev"))}"
}

resource "aws_vpn_gateway" "frankfurt_dev" {
  provider = "aws.frankfurt"
  vpc_id   = "${module.frankfurt_vpc.vpc_id}"

  tags = "${merge(local.amway_common_tags, map("Name", "frankfurt-hybris-dev"))}"
}

resource "aws_vpn_connection" "frankfurt_dev" {
  provider            = "aws.frankfurt"
  vpn_gateway_id      = "${aws_vpn_gateway.frankfurt_dev.id}"
  customer_gateway_id = "${aws_customer_gateway.frankfurt_dev.id}"
  type                = "ipsec.1"
  tunnel1_inside_cidr = "169.254.60.96/30"
  tunnel2_inside_cidr = "169.254.60.100/30"
  static_routes_only  = "false"

  tags = "${merge(local.amway_common_tags, map("Name", "frankfurt-hybris-dev"))}"
}

# VPN Route
resource "aws_vpn_gateway_route_propagation" "frankfurt_dev" {
  provider       = "aws.frankfurt"
  count          = "${length(concat(local.frankfurt_database_subnet_cidrs))}"
  vpn_gateway_id = "${aws_vpn_gateway.frankfurt_dev.id}"
  route_table_id = "${element(module.frankfurt_vpc.database_route_table_ids, count.index)}"
}

# VPN Route public subnets
resource "aws_vpn_gateway_route_propagation" "frankfurt_dev_pub" {
  provider       = "aws.frankfurt"
  count          = "${length(concat(local.frankfurt_public_subnet_cidrs))}"
  vpn_gateway_id = "${aws_vpn_gateway.frankfurt_dev.id}"
  route_table_id = "${element(module.frankfurt_vpc.public_route_table_ids, count.index)}"
}

# SSH
resource "aws_key_pair" "frankfurt_dev" {
  provider   = "aws.frankfurt"
  key_name   = "amway-eu-hybris-dev"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDzlsJbR8ps2/YEJV6orAWJwWUp3oBFP2mhM8ORfmMT9kX4xxpvM3FmdXcwVzUVDMzq7bvULuEzq+03p8AIG7kCPJ1lZH0JYNuLN73SEraornno0rBZv/U8n3Sj+sQEiQBtR/+LGUwqduA5MIHCJwg/yxMEotS3SywZtfz+zymS/gWr5TBtGLH9R2zioOo2DBcV5axZGWby1wQH6eFaiqWkRDzHJLa5cM8VkfjhPsPSCnqh4Z+iQNW8pKiKgSrYW4B9qRybNyGoP754bquyLbSM3YJcI0IiecmXsQhRNmMBCdZ8VoE01xsnzt6Mpl67ZqF8gyxNS69pfDDq0oJWKlqj+nsMSFsMHSflr1NKKGSe8qqLdiFMUY7RUMO5ybnOitehU4KwYd00m/nIxhsxyaPksdhy3fil60eIrFbGOAAXxs9fcbF3BrIT2I663yL6mD/ysaWekdItzOXZmLj6+E0I7D9SB4ZM52OSi/YNcEzIn6tm2ob6lkWyaacsM5y7Ilq8BosC5kEEMbhiqsHfW6N7hANAug2tVuDOfuyyiG9J0EJbuTlyknCD6eOb1dw9s5eGAHN01ZzrUeaOUERbE7xDXv6FKWoNSgfPLsFPoVh0MsQseoSSlSqMZr6JBeFsYC//fgGgV9PSeOEyHvkM4D4/MXeiwEGfx+fNhyObezHe5Q== root@CentOS7x64"

  tags = "${local.amway_common_tags}"
}

resource "aws_acm_certificate" "frankfurt_main" {
  provider          = "aws.frankfurt"
  domain_name       = "*.hybris.eu.eia.amway.net"
  validation_method = "DNS"

  tags = "${merge(local.amway_common_tags, map("Name", "amway-eu-hybris-dev-certificate"))}"

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
