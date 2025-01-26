locals {

  git_org = {
    default = "${var.default_git_org}"
  }

  git_repo = {
    default   = "actions"
    iac       = "lynx-iac"
    provision = "lynx-provision"
    auto      = "AmwayAutoQA"
    lynx      = "lynx"
    dashboard = "lynx-eu-dashboard"
    bamboo-qa = "lynx-bamboo-job-qa"
    bamboodev = "lynx-bamboo-job-dev"
  }

  git_token = {
    default = "${var.git_token}"
  }

  instance_type = {
    default   = "${var.default_instance_type}"
    auto      = "t3a.large"
    lynx      = "t3a.large"
    lynx-ci   = "t3a.xlarge"
    bamboo-qa = "t3a.micro"
  }

  instance_ami = {
    default   = "${var.default_ami}"
    auto      = "ami-07043d7a151cc983d"
    iac       = "ami-0715cf14be57864fb"
    dashboard = "ami-020db6fd42f3bfe26"
    bamboo-qa = "ami-006025a190278d2ea"
    bamboodev = "ami-0e17130c2bca4d3dc"
  }

  instance_disk_size = {
    default   = "${var.default_disk_size}"
    auto      = "50"
    iac       = "8"
    lynx      = "50"
    lynx-ci   = "50"
    bamboo-qa = "150"
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

  skype_url    = var.skype_url
  skype_chan   = var.skype_chan
  skype_secret = var.skype_secret

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
