output "pgsql_rds_root_generated_password" {
  value = "${random_password.pgsql_password.result}"
}

output "pgsql_rds_user_generated_password" {
  value = "${random_password.pgsql_user_password.result}"
}

output "pgsql_rds_endpoint_url" {
  value = "${module.db.this_db_instance_endpoint}"
}
