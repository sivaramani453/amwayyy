provider "aws" {
  region  = "eu-central-1"

}

terraform {

  backend "s3" {
    encrypt        = true
    dynamodb_table = "amway-terraform-lock"
    bucket         = "eu-microservices-preprod-amway-terraform-states"
    key            = "opensearch-eks/opensearch-eks.tfstate"
    region         = "eu-central-1"
  }
}
