provider "aws" {
  region  = "eu-central-1"
#  version = "~> 2.70.0"
#  version = "~> 3.44.0"
}

terraform {
#  required_version = "~> 0.11.13"
#  required_version = "~> 0.14.5"

  backend "s3" {
    encrypt        = true
    dynamodb_table = "amway-terraform-lock"
    bucket         = "amway-terraform-states"
    key            = "vip-reports-frankfurt.tfstate"
    region         = "eu-central-1"
  }
}
