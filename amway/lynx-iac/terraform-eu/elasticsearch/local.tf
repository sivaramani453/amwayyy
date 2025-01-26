locals {
  core_subnet_ids = [
    data.terraform_remote_state.core.outputs.frankfurt_subnet_env_a_id,
    data.terraform_remote_state.core.outputs.frankfurt_subnet_env_b_id,
  ]

  lambda_subnet_ids = [
    data.terraform_remote_state.core.outputs.frankfurt_subnet_lambda_a_id,
    data.terraform_remote_state.core.outputs.frankfurt_subnet_lambda_b_id,
    data.terraform_remote_state.core.outputs.frankfurt_subnet_lambda_c_id,
  ]

  vpn_subnet_cidrs = [
    "10.0.0.0/8",
  ]

  route53_zone_name = "hybris.eu.eia.amway.net"

  amway_common_tags = {
    Terraform     = "true"
    ApplicationID = "APP1433689"
    Environment   = "DEV"
  }

  amway_data_tags = {
    DataClassification = "Internal"
  }
}
