resource "aws_route53_record" "pl_nodes_urls" {
  count   = "${var.ec2_pl_nodes_count}"
  zone_id = "${data.terraform_remote_state.core.route53_zone_id}"
  name    = "${terraform.workspace}-node-${count.index + 1}.ms.eia.amway.net"
  ttl     = "300"
  type    = "A"

  records = ["${element(aws_instance.pl_nodes.*.private_ip, count.index)}"]
}
