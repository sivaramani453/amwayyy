data "terraform_remote_state" "core" {
  backend = "s3"

  config {
    bucket = "amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

locals {
  tags = "${map(
                "Service", "${var.service}",
                "Environment", "${var.environment}",
                "Project", "${data.terraform_remote_state.core.project}"
               )
  }"
}
