data "terraform_remote_state" "core" {
  backend = "s3"

  config {
    bucket = "amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

data "aws_security_group" "main" {
  filter {
    name   = "tag:Name"
    values = ["EIA-Hybris-Trust"]
  }
}

data "aws_ami" "go-grid-router" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["go-grid-router-*"]
  }
}
