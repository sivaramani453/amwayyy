locals {
  ci_subnet_ids = [
    data.terraform_remote_state.core.outputs.frankfurt_subnet_ci_c_id,
  ]

  vpn_subnet_cidrs = [
    "10.0.0.0/8",
  ]

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
