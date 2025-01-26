# Route 53

resource "aws_route53_record" "front_url" {
  zone_id = "${data.terraform_remote_state.core.route53.zone.id}"
  name    = "${var.lb_dns_name}"
  type    = "A"

  alias {
    name                   = "${aws_lb.vault_cluster_lb.dns_name}"
    zone_id                = "${aws_lb.vault_cluster_lb.zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "node_urls" {
  count   = "${length(local.vault_cluster_subnets_ids)}"
  zone_id = "${data.terraform_remote_state.core.route53.zone.id}"
  name    = "${var.vault_cluster_name}-${var.ec2_node_name}-${count.index}.hybris.eia.amway.net"
  ttl     = "300"
  type    = "A"

  records = ["${element(aws_instance.vault_node.*.private_ip, count.index)}"]
}
