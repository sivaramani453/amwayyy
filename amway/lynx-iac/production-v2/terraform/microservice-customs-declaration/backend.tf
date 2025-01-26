provider "aws" {
  version = "~> 2.70.0"
  region  = "eu-central-1"
}

terraform {
  required_version = "~> 0.11.13"

  backend "s3" {
    encrypt        = true
    dynamodb_table = "amway-terraform-lock"
    bucket         = "prod-ru-amway-terraform-states"
    key            = "microservice-customs-declaration-db.tfstate"
    region         = "eu-central-1"
  }
}
