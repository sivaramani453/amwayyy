provider "aws" {
  region = "${data.terraform_remote_state.core.region}"
}

terraform {
  backend "s3" {
    encrypt        = true
    dynamodb_table = "amway-terraform-lock"
    bucket         = "amway-terraform-states"
    key            = "github-middleware.tfstate"
    region         = "eu-central-1"
  }
}
