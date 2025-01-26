locals {
  kube_subnet_cidrs = [
    "${data.aws_subnet.kube-a.cidr_block}",
    "${data.aws_subnet.kube-b.cidr_block}",
    "${data.aws_subnet.kube-c.cidr_block}",
  ]

  address_validation_subnet_cidrs = [
    "${data.aws_subnet.address-validation-a.cidr_block}",
    "${data.aws_subnet.address-validation-b.cidr_block}",
    "${data.aws_subnet.address-validation-c.cidr_block}",
  ]

  vpn_subnet_cidrs = [
    "10.0.0.0/8",
  ]

  address_validation_subnet_ids = [
    "${data.terraform_remote_state.core.frankfurt.subnet.address_validation_a.id}",
    "${data.terraform_remote_state.core.frankfurt.subnet.address_validation_b.id}",
    "${data.terraform_remote_state.core.frankfurt.subnet.address_validation_c.id}",
  ]
}
