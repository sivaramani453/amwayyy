output "cloudfront_domain_name" {
  value = "${aws_cloudfront_distribution.hybris_cf_distribution.domain_name}"
}
