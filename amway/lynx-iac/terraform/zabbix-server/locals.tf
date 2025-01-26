locals {
  amway_application_id {
    default = "APP1433689"
    ru      = "APP3150571"
    eu      = "APP1433689"
  }

  amway_common_tags {
    Name          = "zabbix-server-${terraform.workspace}"
    Terraform     = "True"
    Environment   = "DEV"
    ApplicationID = "${lookup(local.amway_application_id, replace(terraform.workspace, "/(?:.*)(eu|ru)(?:.*)/", "$1"), local.amway_application_id["default"])}"
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
    Service        = "zabbix"
    Project        = "zabbbix-server"
    Tf-Workspace   = "${terraform.workspace}"
    Tf-Application = "zabbix"
  }
}
