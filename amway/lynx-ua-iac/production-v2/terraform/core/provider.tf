provider "aws" {
  version = "~> 2.70.0"
  region  = "eu-central-1"
  alias   = "frankfurt"
}

provider "aws" {
  version = "~> 2.70.0"
  region  = "us-east-1"
  alias   = "virginia"
}
