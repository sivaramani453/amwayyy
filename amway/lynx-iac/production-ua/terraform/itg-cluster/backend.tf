provider "aws" {
  version = "~> 2.22.0"
  region  = "eu-central-1"
}

terraform {
  required_version = "~> 0.11.13"

  backend "s3" {
    encrypt        = true
    dynamodb_table = "amway-terraform-lock"
    bucket         = "prod-amway-terraform-states"
    key            = "itg-cluster.tfstate"
    region         = "eu-central-1"
  }
}
