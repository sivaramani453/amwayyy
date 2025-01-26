data "terraform_remote_state" "core" {
  backend = "s3"

  config = {
    bucket = "eu-microservices-preprod-amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

data "terraform_remote_state" "eks-core" {
  backend = "s3"

  config = {
    bucket = "eu-microservices-preprod-amway-terraform-states"
    key    = "eks-v2/core.tfstate"
    region = "eu-central-1"
  }
}

