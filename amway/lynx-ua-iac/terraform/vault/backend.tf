provider "aws" {
  region  = "${data.terraform_remote_state.core.region}"
  version = "~> 2.5.0"
}

terraform {
  required_version = "~> 0.11.13"

  backend "s3" {
    encrypt        = true
    dynamodb_table = "amway-terraform-lock"
    bucket         = "amway-terraform-states"
    key            = "vault.tfstate"
    region         = "eu-central-1"
  }
}
