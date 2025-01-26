provider "aws" {
  version = "~> 2.31.0"
  region  = "ap-south-1"
}

terraform {
  required_version = "~> 0.11.13"

  backend "s3" {
    encrypt        = true
    dynamodb_table = "amway-terraform-lock"
    bucket         = "prod-amway-terraform-states"
    key            = "microservice-trade-discount-db.tfstate"
    region         = "eu-central-1"
  }
}
