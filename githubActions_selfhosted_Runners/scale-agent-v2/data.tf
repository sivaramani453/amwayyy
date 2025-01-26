# data "terraform_remote_state" "core" {
#   backend = "s3"

#   config = {
#     bucket = "dev-eu-amway-terraform-states"
#     key    = "core/terraform.tfstate"
#     region = "eu-central-1"
#   }
# }

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "aws_s3_bucket" "s3_bucket" {
  bucket = "github-actions-selfhosted-runners-s3"
}

data "terraform_remote_state" "core" {
  backend = "s3"

  config = {
    bucket = "dev-eu-amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

data "aws_vpc" "selvpvected" {
  id = var.vpc_id
}
