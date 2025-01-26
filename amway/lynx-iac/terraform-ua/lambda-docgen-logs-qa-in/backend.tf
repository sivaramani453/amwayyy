provider "aws" {
  version = "~> 2.31.0"
  region  = "ap-south-1"
}

terraform {
  required_version = "~> 0.11.13"

  backend "s3" {
    encrypt        = true
    dynamodb_table = "amway-terraform-lock"
    bucket         = "amway-terraform-states"
    key            = "lambda-docgen-in-qa-logs.tfstate"
    region         = "eu-central-1"
  }
}
