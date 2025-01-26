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

data "aws_ami" "instance_ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["dashboard*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

data "template_file" "userdata" {
  template = "${file("${path.module}/templates/userdata.sh")}"

  vars = {
    s3_bucket_name               = var.s3_bucket_name
    s3_mount_dir                 = var.s3_mount_dir
    s3_mysql_be_bucket_name      = var.s3_mysql_be_bucket_name
    s3_mysql_be_mount_dir        = var.s3_mysql_be_mount_dir
    s3_keys_secret_name          = var.s3_keys_secret_name
    git_user_secret_name         = var.git_user_secret_name
    db_ro_connection_secret_name = var.ga_builds_ro_name
  }
}

