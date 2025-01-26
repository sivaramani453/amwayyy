provider "aws" {
  region = "${data.terraform_remote_state.core.region}"
}

terraform {
  backend "s3" {
    encrypt        = true
    dynamodb_table = "amway-terraform-lock"
    bucket         = "amway-terraform-states"
    key            = "chartmuseum.tfstate"
    region         = "eu-central-1"
  }
}
