provider "aws" {
  version = "~> 2.7.0"
  region  = "eu-central-1"
  alias   = "frankfurt"
}

provider "aws" {
  version = "~> 2.7.0"
  region  = "ap-south-1"
  alias   = "mumbai"
}

provider "aws" {
  version = "~> 2.7.0"
  region  = "us-east-1"
  alias   = "virginia"
}
