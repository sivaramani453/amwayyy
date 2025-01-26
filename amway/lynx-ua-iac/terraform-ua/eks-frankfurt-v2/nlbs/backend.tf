provider "aws" {
  version = "~> 2.40.0"
  region  = "eu-central-1"
}

terraform {
  #  required_version = "~> 0.11.13"

  backend "s3" {
    encrypt        = true
    dynamodb_table = "amway-terraform-lock"
    bucket         = "eu-microservices-preprod-amway-terraform-states"
    key            = "eks-v2/nlbs.tfstate"
    region         = "eu-central-1"
  }
}

