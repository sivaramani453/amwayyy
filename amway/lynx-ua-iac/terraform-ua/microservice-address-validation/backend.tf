provider "aws" {
  region  = "eu-central-1"
  version = "~> 3.42.0"
}

terraform {
  required_version = "~> 0.12"

  backend "s3" {
    encrypt        = true
    dynamodb_table = "amway-terraform-lock"
    bucket         = "eu-microservices-preprod-amway-terraform-states"
    key            = "ms/address-validation.tfstate"
    region         = "eu-central-1"
  }
}