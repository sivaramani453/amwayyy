data "terraform_remote_state" "core" {
  backend = "s3"

  config {
    bucket = "eu-microservices-preprod-amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

/*
data "aws_security_group" "main" {
  filter {
    name   = "tag:Name"
    values = ["EMU Security Group"]
  }
}
*/

data "aws_ami" "vault_node_ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["vault-node*"]
  }
}
