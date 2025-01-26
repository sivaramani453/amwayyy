output "vpc.mumbai_dev.id" {
  value = "${aws_vpc.mumbai_dev.id}"
}

output "vpc.mumbai_dev.cidr_block" {
  value = "${aws_vpc.mumbai_dev.cidr_block}"
}

output "vpc.mumbai_default.id" {
  value = "${aws_default_vpc.mumbai_default.id}"
}

output "vpc.mumbai_default.cidr_block" {
  value = "${aws_default_vpc.mumbai_default.cidr_block}"
}

output "subnet.mumbai_default.mumbai_default_a.id" {
  value = "${aws_default_subnet.mumbai_default_a.id}"
}

output "subnet.mumbai_default.mumbai_default_b.id" {
  value = "${aws_default_subnet.mumbai_default_b.id}"
}

output "subnet.mumbai_default.mumbai_default_c.id" {
  value = "${aws_default_subnet.mumbai_default_c.id}"
}

output "subnet.mumbai_dev.mumbai_dev_lambda_a.id" {
  value = "${aws_subnet.mumbai_dev_lambda_a.id}"
}

output "subnet.mumbai_dev.mumbai_dev_lambda_b.id" {
  value = "${aws_subnet.mumbai_dev_lambda_b.id}"
}

output "subnet.mumbai_dev.mumbai_kubernetes.id" {
  value = "${aws_subnet.mumbai_kubernetes.id}"
}

output "subnet.mumbai_dev.mumbai_kubernetes_rds_a.id" {
  value = "${aws_subnet.mumbai_kubernetes_rds_a.id}"
}

output "subnet.mumbai_dev.mumbai_kubernetes_rds_b.id" {
  value = "${aws_subnet.mumbai_kubernetes_rds_b.id}"
}

output "mumbai.vpc_endpoint.id" {
  value = "${aws_vpc_endpoint.mumbai_private_apigw.id}"
}

output "mumbai.dns.vpc_endpoint.public.all" {
  # first dns entry covers all private ips
  value = "${lookup(aws_vpc_endpoint.mumbai_private_apigw.dns_entry[0], "dns_name")}"
}

output "mumbai.dns.vpc_endpoint.public.1" {
  value = "${lookup(aws_vpc_endpoint.mumbai_private_apigw.dns_entry[1], "dns_name")}"
}

output "mumbai.dns.vpc_endpoint.public.2" {
  value = "${lookup(aws_vpc_endpoint.mumbai_private_apigw.dns_entry[2], "dns_name")}"
}

output "mumbai.dns.vpc_endpoint.private.all" {
  value = "${lookup(aws_vpc_endpoint.mumbai_private_apigw.dns_entry[4], "dns_name")}"
}
