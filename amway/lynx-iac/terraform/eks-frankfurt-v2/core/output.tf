output "vpc_id" {
  value = "${module.frankfurt-eks-vpc.vpc_id}"
}

output "vpc_cidr_block" {
  value = "${module.frankfurt-eks-vpc.vpc_cidr_block}"
}

output "spot_subnets" {
  value = "${aws_subnet.spot_workers.*.id}"
}

output "additional_spot_subnets" {
  value = "${aws_subnet.ondemand_workers.*.id}"
}

output "public_subnets" {
  value = "${module.frankfurt-eks-vpc.public_subnets}"
}

output "private_subnets" {
  value = "${module.frankfurt-eks-vpc.private_subnets}"
}

output "database_subnets" {
  value = "${module.frankfurt-eks-vpc.database_subnets}"
}

output "infra_subnets" {
  value = "${aws_subnet.infra_subnets.*.id}"
}
