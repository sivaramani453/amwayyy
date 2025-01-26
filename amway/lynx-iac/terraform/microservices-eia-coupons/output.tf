output "microservice_url" {
  value = "${aws_route53_record.microservice_url.name}"
}

output "pgsql_rds_endpoint_url" {
  value = "${module.rds_pgsql.this_db_instance_endpoint}"
}
