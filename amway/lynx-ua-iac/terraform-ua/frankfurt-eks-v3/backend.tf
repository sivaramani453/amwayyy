terraform {
  required_version = "~> 0.14.5"

  backend "s3" {
    encrypt        = true
    dynamodb_table = "amway-terraform-lock"
    bucket         = "amway-terraform-states"
    key            = "eks-v3-frankfurt.tfstate"
    region         = "eu-central-1"
  }
}
