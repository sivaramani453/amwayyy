resource "aws_route53_record" "be_nodes_urls" {
  count   = "${var.ec2_be_instance_count}"
  zone_id = "${data.terraform_remote_state.core.route53.zone.id}"
  name    = "be${count.index + 1}-${terraform.workspace}.${data.terraform_remote_state.core.route53.zone.name}"
  ttl     = "300"
  type    = "A"

  records = ["${element(aws_instance.be_nodes.*.private_ip, count.index)}"]
}

resource "aws_route53_record" "fe_nodes_urls" {
  count   = "${var.ec2_fe_instance_count}"
  zone_id = "${data.terraform_remote_state.core.route53.zone.id}"
  name    = "fe${count.index + 1}-${terraform.workspace}.${data.terraform_remote_state.core.route53.zone.name}"
  ttl     = "300"
  type    = "A"

  records = ["${element(aws_instance.fe_nodes.*.private_ip, count.index)}"]
}

resource "aws_route53_record" "alb_backend_url" {
  zone_id = "${data.terraform_remote_state.core.route53.zone.id}"
  name    = "admin-${terraform.workspace}.hybris.eia.amway.net"
  type    = "A"

  alias {
    name                   = "${module.be_alb.dns_name}"
    zone_id                = "${module.be_alb.load_balancer_zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "alb_frontend_url" {
  count   = "${var.r53_records_count}"
  zone_id = "${data.terraform_remote_state.core.route53.zone.id}"
  name    = "${terraform.workspace}.${element(var.r53_countries, count.index)}.hybris.eia.amway.net"
  type    = "A"

  alias {
    name                   = "${module.fe_alb.dns_name}"
    zone_id                = "${module.fe_alb.load_balancer_zone_id}"
    evaluate_target_health = true
  }
}
