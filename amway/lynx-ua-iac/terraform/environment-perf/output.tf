output "be1_id" {
  value = "${aws_instance.backend_node_1.id}"
}

output "be2_id" {
  value = "${aws_instance.backend_node_2.id}"
}

output "fe1_id" {
  value = "${aws_instance.frontend_node_1.id}"
}

output "fe2_id" {
  value = "${aws_instance.frontend_node_2.id}"
}

output "fe3_id" {
  value = "${aws_instance.frontend_node_3.id}"
}

output "fe4_id" {
  value = "${aws_instance.frontend_node_4.id}"
}

output "of1_id" {
  value = "${aws_instance.order_fulfillment_node_1.id}"
}

output "of2_id" {
  value = "${aws_instance.order_fulfillment_node_2.id}"
}

output "solr_master_id" {
  value = "${aws_instance.solr_master_node.id}"
}

output "solr_slave_a_id" {
  value = "${aws_instance.solr_slave_a_node.id}"
}

output "solr_slave_b_id" {
  value = "${aws_instance.solr_slave_b_node.id}"
}

output "be1_private_ip" {
  value = "${aws_instance.backend_node_1.private_ip}"
}

output "be2_private_ip" {
  value = "${aws_instance.backend_node_2.private_ip}"
}

output "fe1_private_ip" {
  value = "${aws_instance.frontend_node_1.private_ip}"
}

output "fe2_private_ip" {
  value = "${aws_instance.frontend_node_2.private_ip}"
}

output "fe3_private_ip" {
  value = "${aws_instance.frontend_node_3.private_ip}"
}

output "fe4_private_ip" {
  value = "${aws_instance.frontend_node_4.private_ip}"
}

output "of1_private_ip" {
  value = "${aws_instance.order_fulfillment_node_1.private_ip}"
}

output "of2_private_ip" {
  value = "${aws_instance.order_fulfillment_node_2.private_ip}"
}

output "solr_master_private_ip" {
  value = "${aws_instance.solr_master_node.private_ip}"
}

output "solr_slave_a_private_ip" {
  value = "${aws_instance.solr_slave_a_node.private_ip}"
}

output "solr_slave_b_private_ip" {
  value = "${aws_instance.solr_slave_b_node.private_ip}"
}

output "env_name" {
  value = "${var.ec2_env_name}"
}

output "db_endpoint" {
  value = "${aws_rds_cluster_instance.perf.endpoint}"
}
