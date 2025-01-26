provider "aws" {
  region = "eu-central-1"
}

terraform {
  #  required_version = "~> 0.11.13"
  required_version = "~> 0.14.0"

  backend "s3" {
    encrypt        = true
    dynamodb_table = "amway-terraform-lock"
    bucket         = "prod-ru-amway-terraform-states"
    key            = "amp.tfstate"
    region         = "eu-central-1"
  }
}
