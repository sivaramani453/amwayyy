output "pgsql_rds_endpoint_url" {
  value = module.rds_pgsql.db_instance_endpoint
}

output "pg_db_name" {
  value = var.pg_db_name
}

output "pg_user_pass" {
  value = var.pg_user_pass
}
