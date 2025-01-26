terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.71.0"
    }
  }
  required_version = "1.9.2"
  
}

provider "external" {

}

provider "aws" { 
  region     = "us-east-1"
}