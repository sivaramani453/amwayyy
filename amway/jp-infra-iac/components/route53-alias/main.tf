data "aws_route53_zone" "zone" {
  name         = var.route53_zone
  private_zone = false
}

resource "aws_route53_record" "record" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.target_name
    zone_id                = var.target_zone_id
    evaluate_target_health = true
  }
}
