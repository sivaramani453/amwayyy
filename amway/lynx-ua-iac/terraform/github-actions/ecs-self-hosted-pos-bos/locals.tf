locals {
  services = [
    {
      # AmwayACS/actions
      git_org            = "AmwayACS"
      git_repo           = "pos-eu"
      git_token          = "${var.git_token}"
      runners            = 5
      labels             = ""
      init_image         = "amway/actions-init:0.1"
      runner_image       = "amway/actions-pos-bos:beta2"
      runner_memory_soft = 1024
    },
  ]

  amway_application_id {
    default = "APP1433689"
    ru      = "APP3150571"
    eu      = "APP1433689"
  }

  amway_common_tags {
    Name          = "${var.cluster_name}"
    Terraform     = "True"
    Environment   = "DEV"
    ApplicationID = "${lookup(local.amway_application_id, replace(terraform.workspace, "/(?:.*)(eu|ru)(?:.*)/", "$1"), local.amway_application_id["default"])}"
  }

  data_tags = {
    DataClassification = "Internal"
  }

  tags = {
    Service        = "github-actions-ecs-self-hosted-pos-bos"
    Project        = "${data.terraform_remote_state.core.project}"
    Tf-Environment = "DEV"
    Tf-Workspace   = "${terraform.workspace}"
    Tf-Application = "github-actions-ecs-self-hosted-pos-bos"
  }
}
