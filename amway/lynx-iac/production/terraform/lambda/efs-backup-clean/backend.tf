provider "aws" {
  version = "~> 2.70.0"
  region  = "eu-central-1"
}

terraform {
  required_version = "~> 0.11.14"

  backend "s3" {
    encrypt        = true
    dynamodb_table = "amway-terraform-lock"
    bucket         = "prod-amway-terraform-states"
    key            = "efs-backup-cleanup.tfstate"
    region         = "eu-central-1"
  }
}
