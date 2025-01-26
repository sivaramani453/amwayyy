output "endpoint_url" {
  value = "${aws_route53_record.main.fqdn}"
}
