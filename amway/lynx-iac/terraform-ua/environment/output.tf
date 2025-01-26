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

output "env_name" {
  value = "${var.ec2_env_name}"
}

output "hosts_ini" {
  value = "${data.template_file.inventory.rendered}"
}
