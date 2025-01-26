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
    key            = "jpn-temporary-cluster-infra"
    region         = "ap-northeast-1"
    dynamodb_table = "jpn-automation-dev-tfstate"
  }
}

provider "aws" {
  region = "ap-northeast-1"
  assume_role {
    role_arn     = "arn:aws:iam::492449516969:role/jpn-automation-dev-deploy"
    session_name = "main-environment"
    external_id  = "main-environment"
  }

  default_tags {
    tags = var.default_tags
  }
}

provider "aws" {
  alias  = "oidc_creator"
  region = "ap-northeast-1"
  assume_role {
    role_arn     = "arn:aws:iam::492449516969:role/oidc-creator-role"
    session_name = "oidc-creator"
    external_id  = "oidc-creator"
  }


  default_tags {
    tags = {
      ApplicationID = "APPXXXXXX",
      Contact       = "anik_barua@amway.com",
      Project       = "preprod",
      Country       = "Japan",
      Environment   = "DEV"
    }
  }
}
