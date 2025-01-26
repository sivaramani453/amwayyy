provider "aws" {
  version = "~> 2.5.0"
  region  = "${data.terraform_remote_state.core.region}"
}

terraform {
  backend "s3" {
    encrypt        = true
    dynamodb_table = "amway-terraform-lock"
    bucket         = "amway-terraform-states"
    key            = "scale-agents.tfstate"
    region         = "eu-central-1"
  }
}
