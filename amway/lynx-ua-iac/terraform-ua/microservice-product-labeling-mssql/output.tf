output "mssql_rds_root_generated_password" {
  value = "${random_password.mssql_password.result}"
}

output "mssql_rds_endpoint_url" {
  value = "${module.rds_mssql.this_db_instance_endpoint}"
}
