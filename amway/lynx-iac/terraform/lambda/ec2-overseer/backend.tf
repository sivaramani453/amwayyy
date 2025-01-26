provider "aws" {
  region  = "eu-central-1"
  version = "~> 2.45.0"
}

terraform {
  required_version = "~> 0.11.14"

  backend "s3" {
    encrypt        = true
    dynamodb_table = "amway-terraform-lock"
    bucket         = "amway-terraform-states"
    key            = "ec2_overseer.tfstate"
    region         = "eu-central-1"
  }
}
