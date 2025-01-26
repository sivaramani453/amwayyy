locals {
  amway_application_id {
    default = "APP1433689"
    ru      = "APP3150571"
    eu      = "APP1433689"
  }

  amway_common_tags {
    Name          = "virginia-vip-reports-${terraform.workspace}"
    Terraform     = "True"
    ApplicationID = "${lookup(local.amway_application_id, replace(terraform.workspace, "/(?:.*)(eu|ru)(?:.*)/", "$1"), local.amway_application_id["default"])}"
    Environment   = "DEV"
  }

  data_tags = {
    DataClassification = "Internal"
  }

  instance_tags = {
    SEC-INFRA-13 = "Appliance"
    SEC-INFRA-14 = "MSP"
    Schedule     = "Running"
  }

  tags = {
    Service        = "virginia-vip-reports"
    Project        = "virginia-vip-reports"
    Tf-Workspace   = "${terraform.workspace}"
    Tf-Application = "virginia-vip-reports"
    Environment    = "DEV"
  }
}
