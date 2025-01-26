output "ip" {
  value = "${aws_instance.zabbix-server.private_ip}"
}

output "dns" {
  value = "${aws_route53_record.zabbix-server.fqdn}"
}
