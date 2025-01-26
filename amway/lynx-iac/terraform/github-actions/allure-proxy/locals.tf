locals {
  amway_application_id {
    default = "APP1433689"
    ru      = "APP3150571"
    eu      = "APP1433689"
  }

  amway_common_tags {
    Name          = "github-actions-allure-proxy-${terraform.workspace}"
    Terraform     = "True"
    Environment   = "DEV"
    ApplicationID = "${lookup(local.amway_application_id, replace(terraform.workspace, "/(?:.*)(eu|ru)(?:.*)/", "$1"), local.amway_application_id["default"])}"
  }

  data_tags = {
    DataClassification = "Internal"
  }

  tags = {
    Service        = "github-actions-allure-proxy"
    Project        = "${data.terraform_remote_state.core.project}"
    Tf-Environment = "DEV"
    Tf-Workspace   = "${terraform.workspace}"
    Tf-Application = "github-actions-allure-proxy"
  }
}
