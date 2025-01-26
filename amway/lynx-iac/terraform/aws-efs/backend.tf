provider "aws" {
  region  = "us-east-1"
  version = "~> 2.5.0"
}

terraform {
  required_version = "~> 0.11.13"

  backend "s3" {
    encrypt        = true
    dynamodb_table = "amway-terraform-lock"
    bucket         = "amway-terraform-states"
    key            = "vip-reports-efs.tfstate"
    region         = "eu-central-1"
  }
}
