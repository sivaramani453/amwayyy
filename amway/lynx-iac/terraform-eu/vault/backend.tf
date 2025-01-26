provider "aws" {
  region  = "us-east-1"

}

# terraform {
#   required_version = "~> 1.8"

#   # backend "s3" {
#   #   encrypt        = true
#   #   dynamodb_table = "amway-terraform-lock"
#   #   bucket         = "dev-eu-amway-terraform-states"
#   #   key            = "vault.tfstate"
#   #   region         = "us-east-1"
#   # }
# }
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = "~> 1.8"
}