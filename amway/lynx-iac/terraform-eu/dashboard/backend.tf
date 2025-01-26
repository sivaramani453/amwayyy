provider "aws" {
  region  = "eu-central-1"
  version = "~> 3.63.0"
}

terraform {
  required_version = "~> 0.12"

  backend "s3" {
    encrypt        = true
    dynamodb_table = "amway-terraform-lock"
    bucket         = "dev-eu-amway-terraform-states"
    key            = "dashboard-eu.tfstate"
    region         = "eu-central-1"
  }
}
