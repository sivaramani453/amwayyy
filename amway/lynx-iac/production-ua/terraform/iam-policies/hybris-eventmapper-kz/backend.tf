provider "aws" {
  version = "~> 2.31.0"
  region  = "us-east-1"
}

terraform {
  required_version = "~> 0.14"

  backend "s3" {
    encrypt        = true
    dynamodb_table = "amway-terraform-lock"
    bucket         = "prod-amway-terraform-states"

    key    = "hybris-eventmapper-ru-iam-kz.tfstate"
    region = "eu-central-1"
  }
}
