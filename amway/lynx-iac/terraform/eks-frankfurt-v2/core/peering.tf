data "terraform_remote_state" "core" {
  backend = "s3"

  config {
    bucket = "amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

resource "aws_vpc_peering_connection" "eks-with-preprod" {
  peer_vpc_id = "${data.terraform_remote_state.core.vpc.dev.id}"
  vpc_id      = "${module.frankfurt-eks-vpc.vpc_id}"
  auto_accept = true

  tags = {
    Name      = "VPC Peering between eks-v2 and eia-hybris preprod"
    Terraform = "true"
  }
}

resource "aws_route" "eks" {
  count                     = "${length(module.frankfurt-eks-vpc.private_subnets)}"
  route_table_id            = "${module.frankfurt-eks-vpc.private_route_table_ids[count.index]}"
  destination_cidr_block    = "${data.terraform_remote_state.core.vpc.dev.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.eks-with-preprod.id}"
  depends_on                = ["module.frankfurt-eks-vpc", "aws_vpc_peering_connection.eks-with-preprod"]
}
