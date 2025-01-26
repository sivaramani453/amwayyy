data "terraform_remote_state" "core" {
  backend = "s3"

  config = {
    bucket = "dev-eu-amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

data "aws_ami" "latest_nexus_ami" {
  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "name"
    values = ["nexus*"]
  }

  owners      = ["self"]
  most_recent = true
}

