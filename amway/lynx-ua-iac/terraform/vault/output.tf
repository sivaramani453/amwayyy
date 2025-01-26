output "vault_cluster_name" {
  value = "${var.vault_cluster_name}"
}

output "vault_node_private_ip" {
  value = "${aws_instance.vault_node.*.private_ip}"
}

output "vault_node_subnet_id" {
  value = "${aws_instance.vault_node.*.subnet_id}"
}

output "vautl_lb_dns_name" {
  value = "${aws_route53_record.front_url.name}"
}

output "vault_s3_data_bucket_name" {
  value = "${aws_s3_bucket.vault_data.bucket}"
}

output "vault_s3_resources_bucket_name" {
  value = "${aws_s3_bucket.vault_resources.bucket}"
}

output "vault_dynamodb_table_name" {
  value = "${aws_dynamodb_table.vault_dynamodb_table.name}"
}
