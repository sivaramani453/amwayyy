output "ec2_mdms_postgresql_instance_endpoint_url" {
  value = "${aws_route53_record.mdms_postgresql_url.name}"
}
