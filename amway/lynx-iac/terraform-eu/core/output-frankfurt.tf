output "frankfurt_route_table_a" {
  value = "${module.frankfurt_vpc.database_route_table_ids[0]}"
}

output "frankfurt_route_table_b" {
  value = "${module.frankfurt_vpc.database_route_table_ids[1]}"
}

output "frankfurt_route_table_c" {
  value = "${module.frankfurt_vpc.database_route_table_ids[2]}"
}

output "frankfurt_dev_vpc_id" {
  value = "${module.frankfurt_vpc.vpc_id}"
}

output "frankfurt_dev_vpc_cidr_block" {
  value = "${module.frankfurt_vpc.vpc_cidr_block}"
}

output "frankfurt_subnet_public_a_id" {
  value = "${module.frankfurt_vpc.public_subnets[0]}"
}

output "frankfurt_subnet_public_b_id" {
  value = "${module.frankfurt_vpc.public_subnets[1]}"
}

output "frankfurt_subnet_public_c_id" {
  value = "${module.frankfurt_vpc.public_subnets[2]}"
}

output "frankfurt_subnet_lambda_a_id" {
  value = "${aws_subnet.frankfurt_lambda.0.id}"
}

output "frankfurt_subnet_lambda_b_id" {
  value = "${aws_subnet.frankfurt_lambda.1.id}"
}

output "frankfurt_subnet_lambda_c_id" {
  value = "${aws_subnet.frankfurt_lambda.2.id}"
}

output "frankfurt_subnet_rds_a_id" {
  value = "${module.frankfurt_vpc.database_subnets[0]}"
}

output "frankfurt_subnet_rds_b_id" {
  value = "${module.frankfurt_vpc.database_subnets[1]}"
}

output "frankfurt_subnet_rds_c_id" {
  value = "${module.frankfurt_vpc.database_subnets[2]}"
}

output "frankfurt_subnet_rds_group" {
  value = "${module.frankfurt_vpc.database_subnet_group}"
}

output "frankfurt_subnet_ci_a_id" {
  value = "${aws_subnet.frankfurt_ci.0.id}"
}

output "frankfurt_subnet_ci_b_id" {
  value = "${aws_subnet.frankfurt_ci.1.id}"
}

output "frankfurt_subnet_ci_c_id" {
  value = "${aws_subnet.frankfurt_ci.2.id}"
}

output "frankfurt_subnet_env_a_id" {
  value = "${aws_subnet.frankfurt_env.0.id}"
}

output "frankfurt_subnet_env_b_id" {
  value = "${aws_subnet.frankfurt_env.1.id}"
}

output "frankfurt_subnet_env_c_id" {
  value = "${aws_subnet.frankfurt_env.2.id}"
}

output "frankfurt_subnet_core_a_id" {
  value = "${aws_subnet.frankfurt_core.0.id}"
}

output "frankfurt_subnet_core_b_id" {
  value = "${aws_subnet.frankfurt_core.1.id}"
}

output "frankfurt_subnet_core_c_id" {
  value = "${aws_subnet.frankfurt_core.2.id}"
}

output "frankfurt_nat_gw_a_id" {
  value = "${module.frankfurt_vpc.natgw_ids[0]}"
}

output "frankfurt_nat_gw_b_id" {
  value = "${module.frankfurt_vpc.natgw_ids[1]}"
}

output "frankfurt_nat_gw_c_id" {
  value = "${module.frankfurt_vpc.natgw_ids[2]}"
}

output "frankfurt_vpc_endpoint_id" {
  value = "${aws_vpc_endpoint.frankfurt_private_apigw.id}"
}

output "frankfurt_dns_vpc_endpoint_public_all" {
  # first dns entry covers all private ips 
  value = "${lookup(aws_vpc_endpoint.frankfurt_private_apigw.dns_entry[0], "dns_name")}"
}

output "frankfurt_dns_vpc_endpoint_public_1" {
  value = "${lookup(aws_vpc_endpoint.frankfurt_private_apigw.dns_entry[1], "dns_name")}"
}

output "frankfurt_dns_vpc_endpoint_public_2" {
  value = "${lookup(aws_vpc_endpoint.frankfurt_private_apigw.dns_entry[2], "dns_name")}"
}

output "frankfurt_dns_vpc_endpoint_public_3" {
  value = "${lookup(aws_vpc_endpoint.frankfurt_private_apigw.dns_entry[3], "dns_name")}"
}

output "frankfurt_dns_vpc_endpoint_private_all" {
  value = "${lookup(aws_vpc_endpoint.frankfurt_private_apigw.dns_entry[4], "dns_name")}"
}

output "frankfurt_ssh_key" {
  value = "${aws_key_pair.frankfurt_dev.key_name}"
}

output "s3_lambda_bucket_name" {
  value = "${module.s3_bucket.bucket_id}"
}

output "dev_debug_iam_instance_profile" {
  value = "${aws_iam_instance_profile.dev_debug.name}"
}
