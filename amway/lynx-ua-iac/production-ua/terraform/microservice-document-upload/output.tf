output "pgsql_rds_root_generated_password" {
  value = "${random_password.pgsql_password.result}"
}

output "pgsql_rds_endpoint_url" {
  value = "${module.rds_pgsql.this_db_instance_endpoint}"
}

output "s3_bucket_name" {
  value = "${module.s3_bucket.bucket_id}"
}

output "s3_bucket_arn" {
  value = "${module.s3_bucket.bucket_arn}"
}
