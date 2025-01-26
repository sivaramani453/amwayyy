output "s3_bucket" {
  value = "${module.s3_bucket.bucket_domain_name}"
}

output "cluster_api" {
  value = "${aws_route53_record.cluster-api.fqdn}"
}

output "monitoring" {
  value = "${aws_route53_record.monitoring.fqdn}"
}
