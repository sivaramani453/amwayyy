locals {
  func_enabled = {
    default = false
    test    = true
  }

  git_token = {
    default = "${var.github_token}"
  }

  git_secret = {
    default = "${var.github_webhook_secret}"
  }

  skype_chat_id = {
    default = "${var.skype_chat_id}"
  }

  skype_secret = {
    default = "${var.skype_secret}"
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
