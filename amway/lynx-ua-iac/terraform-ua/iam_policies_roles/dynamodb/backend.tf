provider "aws" {
  region = "eu-central-1"
}

terraform {
  required_version = "~> 1.0.10"

  backend "s3" {
    encrypt        = true
    dynamodb_table = "amway-terraform-lock"
    bucket         = "amway-terraform-states"
    key            = "CHANGEME.tfstate"
    region         = "eu-central-1"
  }
}
