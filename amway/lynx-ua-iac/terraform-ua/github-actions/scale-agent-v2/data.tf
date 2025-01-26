data "terraform_remote_state" "core" {
  backend = "s3"

  config = {
    bucket = "eu-microservices-preprod-amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}