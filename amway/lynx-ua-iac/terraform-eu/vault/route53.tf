resource "aws_route53_record" "front_url" {
  zone_id = data.terraform_remote_state.core.outputs.route53_zone_id
  name    = "${terraform.workspace}.${local.route53_zone_name}"
  type    = "A"

  alias {
    name                   = module.vault_cluster_lb.this_lb_dns_name
    zone_id                = module.vault_cluster_lb.this_lb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "node_urls" {
  count   = length(local.core_subnet_ids)
  zone_id = data.terraform_remote_state.core.outputs.route53_zone_id
  name    = "${terraform.workspace}-node-${count.index}.${local.route53_zone_name}"
  ttl     = "300"
  type    = "A"

  records = [element(module.vault_cluster.private_ip, count.index)]
}
