data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "terraform_remote_state" "core" {
  backend = "s3"

  config {
    bucket = "amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

data "aws_ami" "allure-ami" {
  most_recent = true
  owners      = ["self", "amazon"]

  filter {
    name   = "name"
    values = ["ga-allure-proxy*"]
  }
}

data "template_file" "userdata" {
  template = "${file("${path.module}/templates/userdata.sh")}"

  vars {
    s3_name    = "amway-dev-${var.s3_name}"
    user_agent = "${var.user_agent}"
  }
}

data "template_file" "bucket_policy" {
  template = "${file("${path.module}/templates/bucket_policy.json")}"

  vars {
    resource_arn = "arn:aws:s3:::amway-dev-${var.s3_name}/*"
    ip_address   = "${var.allow_ip}"
    user_agent   = "${var.user_agent}"
  }
}
