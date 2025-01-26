terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "2.70.0"
    }
    postgresql = {
      source = "cyrilgdn/postgresql"
    }
    random = {
      source = "hashicorp/random"
      version = "2.3.1"
    }
  }
  required_version = ">= 0.11"
}
