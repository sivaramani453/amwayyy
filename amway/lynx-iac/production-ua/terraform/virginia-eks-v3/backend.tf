terraform {
  required_version = "~> 0.14.5"

  backend "s3" {
    encrypt        = true
    dynamodb_table = "amway-terraform-lock"
    bucket         = "prod-ru-amway-terraform-states"

    key    = "virginia-eks-v3-cluster.tfstate"
    region = "eu-central-1"
  }
}
