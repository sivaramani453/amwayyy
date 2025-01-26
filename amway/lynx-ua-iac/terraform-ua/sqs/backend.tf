provider "aws" {
  region = "eu-central-1"
}

terraform {
  backend "s3" {
    encrypt        = true
    dynamodb_table = "amway-terraform-lock"
    bucket         = "amway-terraform-states"
    key            = "sqs-test-ru.tfstate"
    region         = "eu-central-1"
  }
}
