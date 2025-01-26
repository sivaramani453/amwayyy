locals {
  
  git_token = {
    default = "${var.git_token}"
  }

  git_org = {
    default = "${var.default_git_org}"
  }

  git_secret = {
    default = "${var.default_git_secret}"
  }

  git_repo = {
    default   = "actions"
    iac       = "lynx-iac"
    provision = "lynx-provision"
    charts    = "charts"
    auto      = "AmwayAutoQA"
    lynx      = "lynx-test"
    lynx-ci   = "lynx-ci-tests"
    dashboard = "lynx-eu-dashboard"
    bamboodev = "lynx-bamboo-job-dev"
  }

  teams_webhook_url = {
    default = <<EOL
    https://amwaycorp.webhook.office.com/webhookb2/0a0dc835-fe65-4b64-b052-2ed37211d3db@38c3fde4-197b-47b9-9500-769f547df698/IncomingWebhook/dd51d47e777b4d64915c41643d27fa3a/5d4ef13a-73b5-4ec4-8360-ebcfeb4717c8
    https://epam.webhook.office.com/webhookb2/f96ab52f-f6a2-46f6-9063-6fd2bde0ce30@b41b72d0-4e9f-4c26-8a69-f949f367c91d/IncomingWebhook/82a5178714a345d3bb00db9f15a51968/ddd52314-da27-45e9-a3ca-d22551bfcec4
    EOL
    bamboodev = <<EOL
    https://amwaycorp.webhook.office.com/webhookb2/0a0dc835-fe65-4b64-b052-2ed37211d3db@38c3fde4-197b-47b9-9500-769f547df698/IncomingWebhook/dd51d47e777b4d64915c41643d27fa3a/5d4ef13a-73b5-4ec4-8360-ebcfeb4717c8
    https://epam.webhook.office.com/webhookb2/f96ab52f-f6a2-46f6-9063-6fd2bde0ce30@b41b72d0-4e9f-4c26-8a69-f949f367c91d/IncomingWebhook/82a5178714a345d3bb00db9f15a51968/ddd52314-da27-45e9-a3ca-d22551bfcec4
    EOL
    auto = <<EOL
    https://amwaycorp.webhook.office.com/webhookb2/0a0dc835-fe65-4b64-b052-2ed37211d3db@38c3fde4-197b-47b9-9500-769f547df698/IncomingWebhook/dd51d47e777b4d64915c41643d27fa3a/5d4ef13a-73b5-4ec4-8360-ebcfeb4717c8
    https://epam.webhook.office.com/webhookb2/f96ab52f-f6a2-46f6-9063-6fd2bde0ce30@b41b72d0-4e9f-4c26-8a69-f949f367c91d/IncomingWebhook/82a5178714a345d3bb00db9f15a51968/ddd52314-da27-45e9-a3ca-d22551bfcec4
    EOL
  }

  spot_maxprice = {
    default = "0.06"
    bamboodev = "0.06"
  }

  instance_type = {
    default = "${var.default_instance_type}"
    auto    = "t3.large"
    lynx    = "t3.large"
    lynx-ci = "t3.xlarge"
  }

  instance_ami = {
    default   = "${var.default_ami}"
    lynx      = "ami-076caeb22fd600434"
    auto      = "ami-07043d7a151cc983d"
    # "ami-06de50716d83b8361"
    iac       = "ami-0715cf14be57864fb"
    dashboard = "ami-020db6fd42f3bfe26"
    bamboodev = "ami-0cad70c8d146f910e"
  }

  instance_disk_size = {
    default = "${var.default_disk_size}"
    iac     = "8"
    lynx    = "50"
    lynx-ci = "50"
  }

  instance_subnet = {
    default   = data.terraform_remote_state.core.outputs.frankfurt_subnet_ci_a_id
    auto      = data.terraform_remote_state.core.outputs.frankfurt_subnet_ci_b_id
    iac       = data.terraform_remote_state.core.outputs.frankfurt_subnet_ci_c_id
    dashboard = data.terraform_remote_state.core.outputs.frankfurt_subnet_ci_c_id
    bamboodev = data.terraform_remote_state.core.outputs.frankfurt_subnet_ci_c_id
  }

  instance_kp = {
    default = "${var.default_kp}"
  }

  instance_sg = {
    default = "${var.default_sg}"
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
