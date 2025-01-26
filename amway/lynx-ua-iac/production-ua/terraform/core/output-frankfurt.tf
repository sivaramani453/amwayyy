output "frankfurt.route_table_a" {
  value = "${module.frankfurt_vpc.database_route_table_ids[0]}"
}

output "frankfurt.route_table_b" {
  value = "${module.frankfurt_vpc.database_route_table_ids[1]}"
}

output "frankfurt.route_table_c" {
  value = "${module.frankfurt_vpc.database_route_table_ids[2]}"
}

output "frankfurt.prod_vpc.id" {
  value = "${module.frankfurt_vpc.vpc_id}"
}

output "frankfurt.prod_vpc.cidr_block" {
  value = "${module.frankfurt_vpc.vpc_cidr_block}"
}

output "frankfurt.subnet.public_a.id" {
  value = "${module.frankfurt_vpc.public_subnets[0]}"
}

output "frankfurt.subnet.public_b.id" {
  value = "${module.frankfurt_vpc.public_subnets[1]}"
}

output "frankfurt.subnet.public_c.id" {
  value = "${module.frankfurt_vpc.public_subnets[2]}"
}

output "frankfurt.subnet.kubenetes_a.id" {
  value = "${aws_subnet.frankfurt_kubernetes.0.id}"
}

output "frankfurt.subnet.kubenetes_b.id" {
  value = "${aws_subnet.frankfurt_kubernetes.1.id}"
}

output "frankfurt.subnet.kubenetes_c.id" {
  value = "${aws_subnet.frankfurt_kubernetes.2.id}"
}

output "frankfurt.subnet.lambda_a.id" {
  value = "${aws_subnet.frankfurt_lambda.0.id}"
}

output "frankfurt.subnet.lambda_b.id" {
  value = "${aws_subnet.frankfurt_lambda.1.id}"
}

output "frankfurt.subnet.lambda_c.id" {
  value = "${aws_subnet.frankfurt_lambda.2.id}"
}

output "frankfurt.subnet.rds_a.id" {
  value = "${module.frankfurt_vpc.database_subnets[0]}"
}

output "frankfurt.subnet.rds_b.id" {
  value = "${module.frankfurt_vpc.database_subnets[1]}"
}

output "frankfurt.subnet.rds_c.id" {
  value = "${module.frankfurt_vpc.database_subnets[2]}"
}

output "frankfurt.subnet.rds_group" {
  value = "${module.frankfurt_vpc.database_subnet_group}"
}

output "frankfurt.subnet.gitlab_ci_a.id" {
  value = "${aws_subnet.frankfurt_gitlab_ci.0.id}"
}

output "frankfurt.subnet.gitlab_ci_b.id" {
  value = "${aws_subnet.frankfurt_gitlab_ci.1.id}"
}

output "frankfurt.subnet.gitlab_ci_c.id" {
  value = "${aws_subnet.frankfurt_gitlab_ci.2.id}"
}

output "frankfurt.subnet.rancher_a.id" {
  value = "${aws_subnet.frankfurt_rancher.0.id}"
}

output "frankfurt.subnet.rancher_b.id" {
  value = "${aws_subnet.frankfurt_rancher.1.id}"
}

output "frankfurt.subnet.rancher_c.id" {
  value = "${aws_subnet.frankfurt_rancher.2.id}"
}

output "frankfurt.subnet.rancher_alb_a.id" {
  value = "${aws_subnet.frankfurt_rancher_alb.0.id}"
}

output "frankfurt.subnet.rancher_alb_b.id" {
  value = "${aws_subnet.frankfurt_rancher_alb.1.id}"
}

output "frankfurt.subnet.rancher_alb_c.id" {
  value = "${aws_subnet.frankfurt_rancher_alb.2.id}"
}

output "frankfurt.subnet.address_validation_a.id" {
  value = "${aws_subnet.frankfurt_address_validation.0.id}"
}

output "frankfurt.subnet.address_validation_b.id" {
  value = "${aws_subnet.frankfurt_address_validation.1.id}"
}

output "frankfurt.subnet.address_validation_c.id" {
  value = "${aws_subnet.frankfurt_address_validation.2.id}"
}

output "frankfurt.nat.gw_a.id" {
  value = "${module.frankfurt_vpc.natgw_ids[0]}"
}

output "frankfurt.nat.gw_b.id" {
  value = "${module.frankfurt_vpc.natgw_ids[1]}"
}

output "frankfurt.nat.gw_c.id" {
  value = "${module.frankfurt_vpc.natgw_ids[2]}"
}

output "frankfurt.vpc_endpoint.id" {
  value = "${aws_vpc_endpoint.frankfurt_private_apigw.id}"
}

output "frankfurt.dns.vpc_endpoint.public.all" {
  # first dns entry covers all private ips 
  value = "${lookup(aws_vpc_endpoint.frankfurt_private_apigw.dns_entry[0], "dns_name")}"
}

output "frankfurt.dns.vpc_endpoint.public.1" {
  value = "${lookup(aws_vpc_endpoint.frankfurt_private_apigw.dns_entry[1], "dns_name")}"
}

output "frankfurt.dns.vpc_endpoint.public.2" {
  value = "${lookup(aws_vpc_endpoint.frankfurt_private_apigw.dns_entry[2], "dns_name")}"
}

output "frankfurt.dns.vpc_endpoint.public.3" {
  value = "${lookup(aws_vpc_endpoint.frankfurt_private_apigw.dns_entry[3], "dns_name")}"
}

output "frankfurt.dns.vpc_endpoint.private.all" {
  value = "${lookup(aws_vpc_endpoint.frankfurt_private_apigw.dns_entry[4], "dns_name")}"
}

output "frankfurt.ssh_key" {
  value = "${aws_key_pair.amway-microservices-production-frankfurt.key_name}"
}

output "frankfurt.certificate_arn" {
  value = "${aws_acm_certificate.frankfurt_main.arn}"
}

output "s3_lambda_bucket_name" {
  value = "${module.s3_bucket.bucket_id}"
}
