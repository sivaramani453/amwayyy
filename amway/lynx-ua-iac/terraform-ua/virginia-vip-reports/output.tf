output "rds_address_test" {
  value = "${module.db.this_db_instance_address}"
}

output "rds_address_qa" {
  value = "${module.db_qa.this_db_instance_address}"
}
