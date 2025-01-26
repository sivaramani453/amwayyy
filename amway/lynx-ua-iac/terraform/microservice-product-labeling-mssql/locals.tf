locals {
  vpn_subnet_cidrs = [
    "10.0.0.0/8",
    "172.16.0.0/12",
  ]

  custom_tags_common = {
    Terraform     = "True"
    Environment   = "${terraform.workspace}"
    ApplicationID = "APP3150571"
  }

  custom_tags_specific = {
    DataClassification = "Internal"
  }
}
