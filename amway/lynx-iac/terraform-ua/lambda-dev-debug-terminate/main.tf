provider "aws" {
  region  = "eu-central-1"
  version = "~> 2.22.0"
}

data "terraform_remote_state" "core" {
  backend = "s3"

  config {
    bucket = "amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}
