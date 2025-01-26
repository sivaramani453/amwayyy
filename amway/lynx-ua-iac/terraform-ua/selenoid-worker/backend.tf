provider "aws" {
  region  = "eu-central-1"
  version = "~> 2.5.0"
}

terraform {
  required_version = "~> 0.11.13"

  backend "s3" {
    encrypt        = true
    dynamodb_table = "amway-terraform-lock"
    bucket         = "amway-terraform-states"

    #Empty key value to prevent possible tfstate rewriting"
    key    = ""
    region = "eu-central-1"
  }
}
