output "subnet.mgmt.id" {
  value = "${aws_subnet.mgmt.id}"
}

output "subnet.env_a.id" {
  value = "${aws_subnet.environment_a.id}"
}

output "subnet.env_b.id" {
  value = "${aws_subnet.environment_b.id}"
}

output "subnet.env_c.id" {
  value = "${aws_subnet.environment_c.id}"
}

output "subnet.dev_debug.id" {
  value = "${aws_subnet.dev_debug.id}"
}

output "subnet.ci_a.id" {
  value = "${aws_subnet.ci_a.id}"
}

output "subnet.ci_b.id" {
  value = "${aws_subnet.ci_b.id}"
}

output "subnet.ci_c.id" {
  value = "${aws_subnet.ci_c.id}"
}

output "subnet.core_a.id" {
  value = "${aws_subnet.core_a.id}"
}

output "subnet.core_b.id" {
  value = "${aws_subnet.core_b.id}"
}

output "subnet.core_c.id" {
  value = "${aws_subnet.core_c.id}"
}

output "subnet.default_b.id" {
  value = "${aws_subnet.default_b.id}"
}

output "subnet.middleware_b.id" {
  value = "${aws_subnet.middleware_b.id}"
}

output "vpc.dev.id" {
  value = "${aws_vpc.dev.id}"
}

output "vpc.dev.cidr_block" {
  value = "${aws_vpc.dev.cidr_block}"
}

output "vpc.default.id" {
  value = "${aws_vpc.default.id}"
}

output "vpc.default.cidr_block" {
  value = "${aws_vpc.default.cidr_block}"
}

output "region" {
  value = "${data.aws_region.current.name}"
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

output "frankfurt.customer_gateway_id" {
  value = "${aws_customer_gateway.epam_frankfurt.id}"
}

output "s3_lambda_bucket_name" {
  value = "${module.s3_bucket.bucket_id}"
}
