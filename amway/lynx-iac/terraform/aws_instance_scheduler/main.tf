data "terraform_remote_state" "core" {
  backend = "s3"

  config {
    bucket = "amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

locals {
  https_listeners_count = 1

  https_listeners = "${list(
                        map(
                            "certificate_arn", "${var.certificate_arn}",
                            "port", 443
                        )
  )}"

  target_groups_count = 1

  target_groups = "${list(
                        map("name", "${var.service}",
                            "backend_protocol", "HTTP",
                            "backend_port", "${var.container_port}",
                            "slow_start", 0
                        )
  )}"

  tags = {
    Service        = "${var.service}"
    Project        = "${data.terraform_remote_state.core.project}"
    Tf-Environment = "${var.environment}"
    Tf-Workspace   = "${terraform.workspace}"
    Tf-Application = "aws-instance-scheduler"
  }

  ebs_tags = {
    Data-Classificatiion = "Internal"
  }

  target_groups_defaults = "${map(
    "cookie_duration", 86400,
    "deregistration_delay", 300,
    "health_check_interval", 15,
    "health_check_healthy_threshold", 3,
    "health_check_path", "/login",
    "health_check_port", "traffic-port",
    "health_check_timeout", 10,
    "health_check_unhealthy_threshold", 3,
    "health_check_matcher", "200",
    "stickiness_enabled", "false",
    "target_type", "ip",
    "slow_start", 0
  )}"

  amway_application_id {
    default = "APP1433689"
    ru      = "APP3150571"
    eu      = "APP1433689"
  }

  amway_common_tags {
    Name          = "aws-instance-scheduler-${terraform.workspace}"
    Terraform     = "True"
    Environment   = "DEV"
    ApplicationID = "${lookup(local.amway_application_id, replace(terraform.workspace, "/(?:.*)(eu|ru)(?:.*)/", "$1"), local.amway_application_id["default"])}"
  }
}
