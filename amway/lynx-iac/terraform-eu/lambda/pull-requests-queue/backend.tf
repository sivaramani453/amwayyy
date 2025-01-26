provider "aws" {
  region  = "eu-central-1"
  version = "~> 3.55.0"
}

terraform {
  required_version = "~> 0.12"

  backend "s3" {
    encrypt        = true
    dynamodb_table = "amway-terraform-lock"
    bucket         = "dev-eu-amway-terraform-states"
    key            = "pr-queue.tfstate"
    region         = "eu-central-1"
  }
}
