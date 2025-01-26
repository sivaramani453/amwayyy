# resource "aws_route53_record" "front_url" {
#   zone_id = "Z00915472US2M5HIVNQDF"
#   name    = "${terraform.workspace}.${local.route53_zone_name}"
#   type    = "A"

#   alias {
#     name                   = module.vault_cluster_lb.dns_name
#     zone_id                = module.vault_cluster_lb.id
#     evaluate_target_health = true
#   }
# }

# resource "aws_route53_record" "node_urls" {
#   count   = length(local.core_subnet_ids)
#   zone_id = "Z00915472US2M5HIVNQDF"
#   name    = "${terraform.workspace}-node-${count.index}.${local.route53_zone_name}"
#   ttl     = "300"
#   type    = "A"

#   records = [element(module.vault_cluster.private_ip[1], count.index)]
# }
