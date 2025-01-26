data "terraform_remote_state" "core" {
  backend = "s3"

  config {
    bucket = "amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

data "aws_ebs_volume" "media_volume" {
  most_recent = true

  filter {
    name   = "tag:Name"
    values = ["${var.ec2_env_name}-media"]
  }
}

data "aws_ami" "env_ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["environment-perf *"]
  }
}

data "aws_ami" "solr_ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["solr-perf *"]
  }
}
