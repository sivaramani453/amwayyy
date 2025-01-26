terraform {
  required_version = "~> 0.11.13"

  backend "s3" {
    encrypt        = true
    dynamodb_table = "amway-terraform-lock"
    bucket         = "amway-terraform-states"
    key            = "mumbai-kubernetes-cluster.tfstate"
    region         = "eu-central-1"
  }
}
