provider "aws" {
  region  = "eu-central-1"
  version = "~> 2.5.0"
}

terraform {
  required_version = "~> 0.11.13"

  backend "s3" {
    encrypt        = true
    dynamodb_table = "amway-terraform-lock"
    bucket         = "eu-microservices-preprod-amway-terraform-states"
    key            = "vault-ua.tfstate"
    region         = "eu-central-1"
  }
}
