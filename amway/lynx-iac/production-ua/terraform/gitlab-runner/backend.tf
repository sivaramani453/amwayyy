provider "aws" {
  region = "eu-central-1"
  alias  = "frankfurt"
}

terraform {
  required_version = "~> 0.11.13"

  backend "s3" {
    encrypt        = true
    dynamodb_table = "amway-terraform-lock"
    bucket         = "prod-amway-terraform-states"
    key            = "frankfurt-gitlab-runner-terraform.tfstate"
    region         = "eu-central-1"
  }
}
