resource "aws_route53_record" "alb_pl_url" {
  zone_id = "${data.terraform_remote_state.core.route53.zone.id}"
  name    = "${terraform.workspace}.${data.terraform_remote_state.core.route53.zone.name}"
  type    = "A"

  alias {
    name                   = "${module.pl_nodes_alb.dns_name}"
    zone_id                = "${module.pl_nodes_alb.load_balancer_zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "pl_nodes_urls" {
  count   = "${var.ec2_pl_nodes_count}"
  zone_id = "${data.terraform_remote_state.core.route53.zone.id}"
  name    = "${terraform.workspace}-node-${count.index + 1}.${data.terraform_remote_state.core.route53.zone.name}"
  ttl     = "300"
  type    = "A"

  records = ["${element(aws_instance.pl_nodes.*.private_ip, count.index)}"]
}
