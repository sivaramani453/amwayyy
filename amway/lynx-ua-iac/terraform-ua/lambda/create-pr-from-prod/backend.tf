provider "aws" {
  region  = "eu-central-1"
  version = "~> 2.40.0"
}

terraform {
  required_version = "~> 0.11.13"

  backend "s3" {
    encrypt        = true
    dynamodb_table = "amway-terraform-lock"
    bucket         = "amway-terraform-states"
    key            = "create-pr-from-prod"
    region         = "eu-central-1"
  }
}
