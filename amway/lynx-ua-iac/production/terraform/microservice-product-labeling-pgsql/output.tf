output "ec2_product_labeling_postgresql_instance_endpoint_url" {
  value = "${aws_route53_record.product_labeling_postgresql_url.name}"
}

output "efs_endpoint_route53_url" {
  value = "${aws_route53_record.efs_urls.name}"
}
