locals {
  vpn_subnet_cidrs = [
    "10.0.0.0/8",
    "172.16.0.0/12"
  ]

  amway_common_tags = {
    "Terraform"     = "True"
    "Environment"   = var.amway_env_type
    "ApplicationID" = "APP3150571"
  }

  tags = tomap({
    "Name" = "eia-coupons-db",
    "Service" = "coupons",
    "Terraform" = "true",
    "Environment" = "DEV",
    "DataClassification" = "Internal",
    "ApplicationID" = "APP3150571"
  })
}
