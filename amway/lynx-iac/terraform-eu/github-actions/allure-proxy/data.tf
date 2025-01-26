data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "terraform_remote_state" "core" {
  backend = "s3"

  config = {
    bucket = "dev-eu-amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

data "aws_ami" "allure_ami" {
  most_recent = true
  owners      = ["self", "amazon"]

  filter {
    name   = "name"
    values = ["ga-allure-proxy*"]
  }
}

data "template_file" "userdata" {
  template = "${file("${path.module}/templates/userdata.sh")}"

  vars = {
    s3_name    = module.allure_s3_bucket.this_s3_bucket_id
    user_agent = var.user_agent
  }
}

