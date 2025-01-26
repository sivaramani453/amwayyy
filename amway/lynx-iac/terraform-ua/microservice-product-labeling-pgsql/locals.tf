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

  custom_tags_instance = {
    DataClassification = "internal"
    SEC-INFRA-13       = "Appliance"
    SEC-INFRA-14       = "Null"
  }

  custom_tags_volume = {
    DataClassification = "internal"
  }
}
