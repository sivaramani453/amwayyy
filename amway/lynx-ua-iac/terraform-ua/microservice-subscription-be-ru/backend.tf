provider "aws" {
  version = "~> 2.70.0"
  region  = "eu-central-1"
}

terraform {
  required_version = "~> 0.11.13"

  #  required_version = "~> 0.13.0"

  backend "s3" {
    encrypt        = true
    dynamodb_table = "amway-terraform-lock"
    bucket         = "amway-terraform-states"
    key            = "subscription-be-ru.tfstate"
    region         = "eu-central-1"
  }
}
