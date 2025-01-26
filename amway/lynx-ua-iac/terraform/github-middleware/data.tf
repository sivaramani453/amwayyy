data "terraform_remote_state" "core" {
  backend = "s3"

  config {
    bucket = "amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

data "aws_ami" "ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["github-middleware*"]
  }
}
