output "pgsql_rds_root_generated_password" {
  value = random_password.pgsql_password.result
}

output "pgsql_rds_endpoint_url" {
  value = "module.rds_pgsql.this_db_instance_endpoint"
}

output "pg_db_name" {
  value = var.pg_db_name
}

output "pg_user_name" {
  value = var.pg_user_name
}

output "pg_ro_user_name" {
  value = var.pg_ro_user_name
}
output "pg_user_pass" {
  value = var.pg_user_pass
}

output "pg_ro_user_pass" {
  value = var.pg_ro_user_pass
}
