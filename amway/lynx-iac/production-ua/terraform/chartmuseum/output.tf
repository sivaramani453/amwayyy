output "chartmuseum_absolute_url" {
  value = "https://${aws_route53_record.chartmuseum.fqdn}"
}

output "bucket" {
  value = "${module.s3_bucket.bucket_id}"
}
