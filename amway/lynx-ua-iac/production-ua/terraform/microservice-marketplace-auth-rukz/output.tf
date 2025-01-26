output "pgsql_rds_root_generated_password" {
  value = random_password.pgsql_password.result
}

output "pgsql_rds_endpoint_url" {
  value = "module.rds_pgsql.this_db_instance_endpoint"
}

output "s3_bucket_name" {
  value = "amway-prod-ru-microservice-${var.dns}"
}

output "pg_user_pass" {
  value = var.pg_user_pass
}

output "cloudfront_domain_name" {
  value = local.cloudfront_domain
}
