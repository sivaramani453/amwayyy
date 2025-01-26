output "s3_bucket_name" {
  value = "amway-dev-microservice-${terraform.workspace}"
}

output "cloudfront_domain_name" {
  value = "${local.cloudfront_domain}"
}
