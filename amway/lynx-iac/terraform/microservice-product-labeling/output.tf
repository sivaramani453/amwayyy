output "pl_private_ips" {
  value = "${aws_instance.pl_nodes.*.private_ip}"
}

output "pl_node_urls" {
  value = "${aws_route53_record.pl_nodes_urls.*.name}"
}

output "hosts_ini" {
  value = "${data.template_file.hosts.rendered}"
}
