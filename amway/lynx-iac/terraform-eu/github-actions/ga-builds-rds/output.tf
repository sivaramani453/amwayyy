output "db_instance_endpoint" {
  description = "The connection endpoint"
  value       = module.db.this_db_instance_endpoint
}

output "db_instance_username" {
  description = "The master username for the database"
  value       = module.db.this_db_instance_username
  sensitive   = true
}

output "db_master_password" {
  description = "The database master password"
  value       = module.db.this_db_master_password
  sensitive   = true
}
