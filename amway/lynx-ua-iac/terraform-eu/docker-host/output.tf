output "docker_host_private_dns" {
  value = module.docker_host.private_dns
}

output "docker_host_private_ip" {
  value = module.docker_host.private_ip
}

output "docker_host_route53_records" {
  value = "${aws_route53_record.docker_host_urls.*.name}"
}
