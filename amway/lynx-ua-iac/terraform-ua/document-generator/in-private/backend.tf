provider "aws" {
  version = "~> 2.40.0"
  region  = "ap-south-1"
}

terraform {
  required_version = "~> 0.11.13"

  backend "s3" {
    encrypt        = true
    dynamodb_table = "amway-terraform-lock"
    bucket         = "amway-terraform-states"
    key            = "in-qa-document-generator.tfstate"
    region         = "eu-central-1"
  }
}
