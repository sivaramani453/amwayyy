terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.44.0"
    }
    postgresql = {
      source = "cyrilgdn/postgresql"
      version = "~> 1.13.0"
    }
  }
  required_version = ">= 0.13"
}
