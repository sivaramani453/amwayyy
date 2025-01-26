locals {
  vpn_subnet_cidrs = [
    "10.0.0.0/8",
    "172.16.0.0/12",
  ]

  amway_tags = map(
         "Terraform", "True",
         "Evironment", "PROD",
         "DataClassification", "Internal",
         "ApplicationID", "APP3150571")

  cloudfront_domain = var.dns
}
