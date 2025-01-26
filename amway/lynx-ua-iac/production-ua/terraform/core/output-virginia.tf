output "virginia.route_table_a" {
  value = "${module.virginia_vpc.database_route_table_ids[0]}"
}

output "virginia.route_table_b" {
  value = "${module.virginia_vpc.database_route_table_ids[1]}"
}

output "virginia.route_table_c" {
  value = "${module.virginia_vpc.database_route_table_ids[2]}"
}

output "virginia.route_table_d" {
  value = "${module.virginia_vpc.database_route_table_ids[3]}"
}

output "virginia.route_table_e" {
  value = "${module.virginia_vpc.database_route_table_ids[4]}"
}

output "virginia.route_table_f" {
  value = "${module.virginia_vpc.database_route_table_ids[5]}"
}

output "virginia.prod_vpc.id" {
  value = "${module.virginia_vpc.vpc_id}"
}

output "virginia.prod_vpc.cidr_block" {
  value = "${module.virginia_vpc.vpc_cidr_block}"
}

output "virginia.subnet.public_a.id" {
  value = "${module.virginia_vpc.public_subnets[0]}"
}

output "virginia.subnet.public_b.id" {
  value = "${module.virginia_vpc.public_subnets[1]}"
}

output "virginia.subnet.public_c.id" {
  value = "${module.virginia_vpc.public_subnets[2]}"
}

output "virginia.subnet.public_d.id" {
  value = "${module.virginia_vpc.public_subnets[3]}"
}

output "virginia.subnet.public_e.id" {
  value = "${module.virginia_vpc.public_subnets[4]}"
}

output "virginia.subnet.public_f.id" {
  value = "${module.virginia_vpc.public_subnets[5]}"
}

output "virginia.subnet.kubenetes_a.id" {
  value = "${aws_subnet.virginia_kubernetes.0.id}"
}

output "virginia.subnet.kubenetes_b.id" {
  value = "${aws_subnet.virginia_kubernetes.1.id}"
}

output "virginia.subnet.kubenetes_c.id" {
  value = "${aws_subnet.virginia_kubernetes.2.id}"
}

output "virginia.subnet.kubenetes_d.id" {
  value = "${aws_subnet.virginia_kubernetes.3.id}"
}

output "virginia.subnet.kubenetes_e.id" {
  value = "${aws_subnet.virginia_kubernetes.4.id}"
}

output "virginia.subnet.kubenetes_f.id" {
  value = "${aws_subnet.virginia_kubernetes.5.id}"
}

output "virginia.subnet.lambda_a.id" {
  value = "${aws_subnet.virginia_lambda.0.id}"
}

output "virginia.subnet.lambda_b.id" {
  value = "${aws_subnet.virginia_lambda.1.id}"
}

output "virginia.subnet.lambda_c.id" {
  value = "${aws_subnet.virginia_lambda.2.id}"
}

output "virginia.subnet.lambda_d.id" {
  value = "${aws_subnet.virginia_lambda.3.id}"
}

output "virginia.subnet.lambda_e.id" {
  value = "${aws_subnet.virginia_lambda.4.id}"
}

output "virginia.subnet.lambda_f.id" {
  value = "${aws_subnet.virginia_lambda.5.id}"
}

output "virginia.subnet.rds_a.id" {
  value = "${module.virginia_vpc.database_subnets[0]}"
}

output "virginia.subnet.rds_b.id" {
  value = "${module.virginia_vpc.database_subnets[1]}"
}

output "virginia.subnet.rds_c.id" {
  value = "${module.virginia_vpc.database_subnets[2]}"
}

output "virginia.subnet.rds_d.id" {
  value = "${module.virginia_vpc.database_subnets[3]}"
}

output "virginia.subnet.rds_e.id" {
  value = "${module.virginia_vpc.database_subnets[4]}"
}

output "virginia.subnet.rds_f.id" {
  value = "${module.virginia_vpc.database_subnets[5]}"
}

output "virginia.subnet.rds_group" {
  value = "${module.virginia_vpc.database_subnet_group}"
}

output "virginia.nat.gw_a.id" {
  value = "${module.virginia_vpc.natgw_ids[0]}"
}

output "virginia.nat.gw_b.id" {
  value = "${module.virginia_vpc.natgw_ids[1]}"
}

output "virginia.nat.gw_c.id" {
  value = "${module.virginia_vpc.natgw_ids[2]}"
}

output "virginia.nat.gw_d.id" {
  value = "${module.virginia_vpc.natgw_ids[3]}"
}

output "virginia.nat.gw_e.id" {
  value = "${module.virginia_vpc.natgw_ids[4]}"
}

output "virginia.nat.gw_f.id" {
  value = "${module.virginia_vpc.natgw_ids[5]}"
}

output "virginia.ssh_key" {
  value = "${aws_key_pair.amway-microservices-production-virginia.key_name}"
}

output "virginia.certificate_arn" {
  value = "${aws_acm_certificate.virginia_main.arn}"
}
