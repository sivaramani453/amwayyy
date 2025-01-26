terraform {
  backend "s3" {
    encrypt        = true
    dynamodb_table = "amway-terraform-lock"
    bucket         = "amway-terraform-states"
    key            = "nexus.tfstate"
    region         = "eu-central-1"
  }
}
