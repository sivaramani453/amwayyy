locals {
  tags {
    Terraform     = "true"
    ApplicationID = "${var.app_id}"
    Environment   = "${var.app_env}"
  }
}
