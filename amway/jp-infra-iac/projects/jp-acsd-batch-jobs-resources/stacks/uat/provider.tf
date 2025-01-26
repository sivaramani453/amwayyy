terraform {
  required_version = "~> 1.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.0"
    }
  }
  backend "s3" {
    bucket         = "jpn-automation-dev-tfstate"
    key            = "jp-acsd-pss-data-resources-uat"
    region         = "ap-northeast-1"
    dynamodb_table = "jpn-automation-dev-tfstate"
  }
}

provider "aws" {
  region = "ap-northeast-1"
  assume_role {
    role_arn     = "arn:aws:iam::417642731771:role/jpn-dev-cicd-infra-deployment"
    session_name = "automation"
    external_id  = "automation"
  }

  default_tags {
    tags = var.default_tags
  }
}
