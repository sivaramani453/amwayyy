provider "aws" {
  version = "~> 2.45.0"
  region  = "eu-central-1"
}

terraform {
  required_version = "~> 0.11.14"

  backend "s3" {
    encrypt        = true
    dynamodb_table = "amway-terraform-lock"
    bucket         = "amway-terraform-states"
    key            = "microservice-prerender.tfstate"
    region         = "eu-central-1"
  }
}
