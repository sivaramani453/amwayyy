provider "aws" {
  version = "~> 2.70.0"
  region  = "eu-central-1"
  alias   = "frankfurt"
}

terraform {
  required_version = "~> 0.11.13"

  backend "s3" {
    encrypt        = true
    dynamodb_table = "amway-terraform-lock"
    bucket         = "dev-eu-amway-terraform-states"
    key            = "core/terraform.tfstate"
    region         = "eu-central-1"
  }
}
