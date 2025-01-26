locals {
  core_subnet_ids = toset([
    data.aws_subnet.subnet1.id,
    data.aws_subnet.subnet3.id,
    data.aws_subnet.subnet2.id,
  ])

  vpn_subnet_cidrs = [
    "10.10.0.0/20",
  ]

  route53_zone_name = "sivalearning.xyz"

  lb_certificate_arn = "arn:aws:acm:us-east-1:729093267362:certificate/cdd7ea80-ca80-4479-974a-fca2f95a708c"

  lb_ssl_policy      = "ELBSecurityPolicy-TLS-1-2-2017-01"

  amway_common_tags = {
    Terraform     = "true"
    ApplicationID = "APP1433689"
    Environment   = "DEV"
  }

  amway_ec2_tags = {
    ITAM-SAM           = "MSP"
    DataClassification = "Internal"
    SEC-INFRA-13       = "Appliance"
    SEC-INFRA-14       = "MSP"
    Schedule           = "running"
  }

  amway_data_tags = {
    DataClassification = "Internal"
  }
}

