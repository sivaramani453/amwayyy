terraform {
  required_version = "~> 1.5"

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
    key            = "CUSTOMIZE-ME-infra"
    region         = "ap-northeast-1"
    dynamodb_table = "jpn-automation-dev-tfstate"
  }
}

# Add providers here...
