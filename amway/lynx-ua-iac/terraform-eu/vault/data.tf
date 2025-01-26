data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "terraform_remote_state" "core" {
  backend = "s3"

  config = {
    bucket = "dev-eu-amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

data "aws_ami" "vault_node_ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["vault-node*"]
  }
}
