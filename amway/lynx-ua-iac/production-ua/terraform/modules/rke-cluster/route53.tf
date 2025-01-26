resource "aws_route53_record" "kube-api" {
  count   = "${var.create_route53 ? 1 : 0 }"
  zone_id = "${var.route53_zone_id}"
  name    = "${var.cluster_name}.${var.route53_zone_name}"
  type    = "A"

  alias {
    name                   = "${module.load_balancer.dns_name}"
    zone_id                = "${module.load_balancer.zone_id}"
    evaluate_target_health = true
  }
}
