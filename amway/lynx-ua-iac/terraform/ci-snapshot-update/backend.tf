provider "aws" {
  region  = "eu-central-1"
  version = "~> 2.70.0"
}

terraform {
  required_version = "~> 0.11.14"

  backend "s3" {
    encrypt        = true
    dynamodb_table = "amway-terraform-lock"
    bucket         = "amway-terraform-states"
    key            = "ci-snapshot-update.tfstate"
    region         = "eu-central-1"
  }
}
