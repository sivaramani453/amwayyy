terraform {
  required_version = "~> 1.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  backend "s3" {
    bucket         = "jpn-automation-prod-tfstate"
    key            = "jp-cicd-gha-runner-container"
    region         = "ap-northeast-1"
    dynamodb_table = "jpn-automation-prod-tfstate"
  }
}

provider "aws" {
  region = "ap-northeast-1"
  assume_role {
    role_arn     = "arn:aws:iam::074806990885:role/jpn-automation-prod-deploy"
    session_name = "automation"
    external_id  = "automation"
  }

  default_tags {
    tags = var.default_tags
  }
}
