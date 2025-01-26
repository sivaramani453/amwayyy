provider "aws" {
  version = "~> 2.31.0"
  region  = "us-east-1"
}

terraform {
  required_version = "~> 0.11.13"

  backend "s3" {
    encrypt        = true
    dynamodb_table = "amway-terraform-lock"
    bucket         = "prod-amway-terraform-states"

    key    = "microservice-eia-blocks-db.tfstate"
    region = "eu-central-1"
  }
}
