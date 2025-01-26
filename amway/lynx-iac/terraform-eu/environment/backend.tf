provider "aws" {
  region  = "eu-central-1"
  version = "~> 3.24.1"
}

# provider "aws" {
#   region  = "eu-central-1"
#   version = "~> 3.24.1"
#   alias   = "epam_ru"

#   assume_role {
#     role_arn = "arn:aws:iam::860702706577:role/amway-eu-epam-new-account-iam-role"
#   }
# }


terraform {
  required_version = "~> 0.12"

  backend "s3" {
    encrypt        = true
    dynamodb_table = "amway-terraform-lock"
    bucket         = "dev-eu-amway-terraform-states"
    key            = "environment-deploy-eu.tfstate"
    region         = "eu-central-1"
  }
}
