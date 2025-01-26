provider "aws" {
  region  = "eu-central-1"
}

terraform {
  backend "s3" {
    encrypt        = true
    dynamodb_table = "amway-terraform-lock"
    bucket         = "prod-ru-amway-terraform-states"
    key            = "hybris-cloudfront.tfstate"
    region         = "eu-central-1"
  }
}
