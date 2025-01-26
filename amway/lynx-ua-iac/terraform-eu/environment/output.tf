output "be1_id" {
  value = element(aws_instance.be_nodes.*.id, 0)
}

output "be2_id" {
  value = element(aws_instance.be_nodes.*.id, 1)
}

output "fe1_id" {
  value = element(aws_instance.fe_nodes.*.id, 0)
}

output "fe2_id" {
  value = element(aws_instance.fe_nodes.*.id, 1)
}

output "be1_private_ip" {
  value = element(aws_instance.be_nodes.*.private_ip, 0)
}

output "be2_private_ip" {
  value = element(aws_instance.be_nodes.*.private_ip, 1)
}

output "fe1_private_ip" {
  value = element(aws_instance.fe_nodes.*.private_ip, 0)
}

output "fe2_private_ip" {
  value = element(aws_instance.fe_nodes.*.private_ip, 1)
}

output "be1_node_fqdn" {
  value = element(aws_route53_record.be_nodes_urls.*.name, 0)
}

output "be2_node_fqdn" {
  value = element(aws_route53_record.be_nodes_urls.*.name, 1)
}

output "fe1_node_fqdn" {
  value = element(aws_route53_record.fe_nodes_urls.*.name, 0)
}

output "fe2_node_fqdn" {
  value = element(aws_route53_record.fe_nodes_urls.*.name, 1)
}

output "env_name" {
  value = terraform.workspace
}

output "hosts_ini" {
  value = data.template_file.inventory.rendered
}
