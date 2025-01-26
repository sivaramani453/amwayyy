output "project" {
  value = "amway"
}

output "route53.zone.id" {
  value = "${aws_route53_zone.main.zone_id}"
}

output "route53.zone.name" {
  value = "hybris.eia.amway.net"
}
