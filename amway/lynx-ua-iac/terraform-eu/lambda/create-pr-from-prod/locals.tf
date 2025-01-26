locals {

  code_repo = {
    eu = "${var.eu_code_repo}"
  }

  config_repo = {
    eu = "${var.eu_config_repo}"
  }

  branches = {
    eu = "${var.git_eu_branches}"
  }

  teams_channel = {
    eu = "${var.teams_eu_channel}"
  }

  lambda_subnet_ids = [
    data.terraform_remote_state.core.outputs.frankfurt_subnet_lambda_a_id,
    data.terraform_remote_state.core.outputs.frankfurt_subnet_lambda_b_id,
    data.terraform_remote_state.core.outputs.frankfurt_subnet_lambda_c_id,
  ]

  vpn_subnet_cidrs = [
    "10.0.0.0/8",
  ]

  amway_common_tags = {
    Terraform     = "true"
    ApplicationID = "APP1433689"
    Environment   = "DEV"
  }

  amway_data_tags = {
    DataClassification = "Internal"
  }
}
