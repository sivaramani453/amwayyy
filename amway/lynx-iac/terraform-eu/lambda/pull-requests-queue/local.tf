locals {

  git_token = {
    eu = "${var.git_eu_token}"
  }

  teams_secret = {
    eu = "${var.teams_eu_secret}"
  }

  branches_list = {
    eu = ["dev-dev", "dev-rel", "support-dev", "support-rel"]
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
