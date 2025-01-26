data "aws_region" "current" {}
data "aws_caller_identity" "current" {}


data "aws_vpc" "vpc" {
  id = "vpc-07936173d92ae10ab"
}

data "aws_subnet" "subnet1" {
  id = "subnet-0ec5415d63ebab836"
}
data "aws_subnet" "subnet2" {
  id = "subnet-05fce15df271f83c9"
}
data "aws_subnet" "subnet3" {
  id = "subnet-0d30dea67efbea895"
}



# data "terraform_remote_state" "core" {
#   backend = "s3"

#   config = {
#     bucket = "dev-eu-amway-terraform-states"
#     key    = "core/terraform.tfstate"
#     region = "eu-central-1"
#   }
# }

data "aws_ami" "vault_node_ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["vault-node*"]
  }
}
