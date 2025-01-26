provider "aws" {
  region  = "eu-central-1"
  version = "~> 3.42.0"
}

# without following it does not want to initialize, as it claims that external version
# is 2.X.X, while last compatible is the one I specify down here:
provider "external" {
  version = "1.1.0"
}

terraform {
  required_version = "~> 0.12"

  backend "s3" {
    encrypt        = true
    dynamodb_table = "amway-terraform-lock"
    bucket         = "dev-eu-amway-terraform-states"
    key            = "lambda-gh-scale-agent-v2.tfstate"
    region         = "eu-central-1"
  }
}
