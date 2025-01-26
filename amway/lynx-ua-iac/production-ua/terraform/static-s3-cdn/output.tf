
output "s3_bucket_name" {
  value = "amway-prod-ru-microservice-${var.dns}"
}

output "cloudfront_domain_name" {
  value = local.cloudfront_domain
}
