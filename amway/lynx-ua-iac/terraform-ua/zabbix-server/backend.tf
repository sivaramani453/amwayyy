provider "aws" {
  version = "~> 2.7.0"
  region  = "eu-central-1"
}

terraform {
  required_version = "~> 0.11.13"

  backend "s3" {
    encrypt        = true
    dynamodb_table = "amway-terraform-lock"
    bucket         = "amway-terraform-states"
    key            = "zabbix-server.tfstate"
    region         = "eu-central-1"
  }
}
