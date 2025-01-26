output "ip" {
  value = module.zabbix_server.private_ip
}

output "dns" {
  value = aws_route53_record.zabbix_server.fqdn
}
