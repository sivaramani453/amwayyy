terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.37.0"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.13.0-pre1"
    }
    random = {
      source  = "hashicorp/random"
    }
  }
  required_version = ">= 0.13"
}
