output "ssl_certificate" {
  value = module.nginx_ingress_ssl_certificate.acm_certificate
}

output "ingress" {
  value = module.ingress.ingress
}

output "nlb" {
  value = data.aws_lb.nlb
}
