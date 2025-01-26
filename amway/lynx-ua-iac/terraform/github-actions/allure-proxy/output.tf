output "proxy_url" {
  value = "https://${aws_route53_record.alias.fqdn}"
}
